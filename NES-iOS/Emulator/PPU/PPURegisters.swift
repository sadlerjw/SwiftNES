//
//  Registers.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//

extension PPU {
    class Registers : Addressable {
        struct PPUCTRL : OptionSet {    // Misc PPU settings
            var rawValue: Byte
            
            static let nametableX = PPUCTRL(rawValue: 1 << 0)                   // Can be interpreted as X scroll position bit 8
            static let nametableY = PPUCTRL(rawValue: 1 << 1)                   // Can be interpreted as Y scroll position bit 8
            static let vramAddressIncrementMode = PPUCTRL(rawValue: 1 << 2)     // Increment by 1 if 0; otherwise increment by 32
            static let spritePatternTableAddress = PPUCTRL(rawValue: 1 << 3)    // For 8x8 sprites. Ignored in 8x16 mode
                                                                                // 0x0000 when 0; otherwise 0x1000
            static let backgroundPatternTableAddress = PPUCTRL(rawValue: 1 << 4) // 0x0000 when 0; otherwise 0x1000
            static let spriteSize = PPUCTRL(rawValue: 1 << 5)                   // 8x8 when 0; otherwise 8x16
            static let secondarySelect = PPUCTRL(rawValue: 1 << 6)              // Always disabled
            static let vblankNMI = PPUCTRL(rawValue: 1 << 7)                    // When 1, NMI handler is called at start of vblank
                                                                                // If set to 1 while in vblank, NMI happens immediately
        }
        
        struct PPUMASK : OptionSet {    // Rendering settings
            var rawValue: Byte
            
            static let greyscale = PPUMASK(rawValue: 1 << 0)        // Force greyscale by ANDing colour with 0x30 to force them to use the grey column
            static let renderLeftBackgroundBorder = PPUMASK(rawValue: 1 << 1)
            static let renderLeftSpritsBorder = PPUMASK(rawValue: 1 << 2)
            static let renderBackground = PPUMASK(rawValue: 1 << 3)
            static let renderSprites = PPUMASK(rawValue: 1 << 4)
            static let emphasizeRed = PPUMASK(rawValue: 1 << 5)     // https://www.nesdev.org/wiki/Colour_emphasis
            static let emphasizeGreen = PPUMASK(rawValue: 1 << 6)
            static let emphasizeBlue = PPUMASK(rawValue: 1 << 7)
        }
        
        struct PPUStatus : OptionSet {    // Rendering events
            var rawValue: Byte
            
            // Bits 0 through 4 are unused...
            
            // All 3 of these flags are cleared on dot 1 of the prerender scanline
            static let spriteOverflow = PPUStatus(rawValue: 1 << 5)
            static let spriteZeroHit = PPUStatus(rawValue: 1 << 6)
            static let vblank = PPUStatus(rawValue: 1 << 7)   // Cleared on read
        }
        
        let length = 0x8
        let name: String = "PPU registers"
        unowned let ppu: PPU
        
        private var latchedValue : Byte = 0
        var ppuDataBuffer : Byte = 0
        
        init(ppu: PPU) {
            self.ppu = ppu
        }

        func write(_ value: Byte, at offset: Offset) {
            latchedValue = value
            
            switch offset {
            case 0: // PPUCTRL
                ppu.control = PPUCTRL(rawValue: value)
            case 1: // PPUMASK
                ppu.mask = PPUMASK(rawValue: value)
            case 2: // PPUSTATUS
                break   // status is read-only
            case 3: // OAMADDR
                ppu.oamAddress = value
                break
            case 4: // OAMDATA
                ppu.oam.raw.write(value, at: Address(ppu.oamAddress))
                ppu.oamAddress &+= 1
            case 5: // PPUSCROLL
                if !ppu.w {
                    ppu.t.coarseXScroll = (value & 0xF8) >> 3  // The high 5 bits go in t
                    ppu.x = value & 0x7                 // The low 3 bits go in x
                } else {
                    ppu.t.coarseYScroll = (value & 0xF8) >> 3  // The high 5 bits go in t
                    ppu.t.fineYScroll = value & 0x7     // The low 3 bits go elsewhere in t
                }
                ppu.w.toggle()
            case 6: // PPUADDR
                let reg = ppu.t.rawValue.reg
                if !ppu.w {
                    // Replace the high byte of t with value (but zero out the highest two bits)
                    ppu.t.rawValue.reg = (reg & 0x00FF) | (UInt16(value) << 8 & 0x3F00)
                } else {
                    // Replace the low byte of t with value
                    ppu.t.rawValue.reg = (reg & 0xFF00) | UInt16(value)
                    // Copy t into v
                    ppu.v.rawValue.reg = ppu.t.rawValue.reg
                }
                ppu.w.toggle()
            case 7: // PPUDATA
                ppu.bus.write(value, at: ppu.t.rawValue.reg)
                let incrementedAddress = (ppu.t.rawValue.reg &+ (ppu.control.contains(.vramAddressIncrementMode) ? 32 : 1))
                ppu.t.rawValue.reg = incrementedAddress & 0x3FFF    // Truncate the result at 14 bits
            default:
                fatalError("Received impossible offset \(offset) in PPU.Registers")
                break
            }
        }
        
        func read(at offset: Offset) -> Byte {
            switch offset {
            case 0: // PPUCTRL is write-only
                break
            case 1: // PPUMASK is write-only
                break
            case 2: // PPUSTATUS
                // Reading this register has the side effect of clearing the
                // PPU's internal w register
                ppu.w = false
                
                latchedValue = ppu.status.rawValue
                
                // vblank gets cleared on read according to https://www.nesdev.org/wiki/PPU_registers#PPUSTATUS
                ppu.status.remove(.vblank)
            case 3: // OAMADDR is write-only
                break
            case 4: // OAMDATA
                latchedValue = ppu.oam.raw.read(at: Address(ppu.oamAddress))
            case 5: // PPUSCROLL is write-only
                break
            case 6: // PPUADDR is read-only
                break
            case 7: // PPUDATA
                let address = ppu.t.rawValue.reg
                
                // PPUDATA reads are delayed by one access to PPUDATA, so
                // we use a buffer to do that.
                latchedValue = ppuDataBuffer
                ppuDataBuffer = ppu.bus.read(address)
                let incrementedAddress = (address &+ (ppu.control.contains(.vramAddressIncrementMode) ? 32 : 1))
                ppu.t.rawValue.reg = incrementedAddress & 0x3FFF    // Truncate the result at 14 bits
                
                if address >= NES.PPUBusAddresses.paletteRAMIndexesStart && address <= NES.PPUBusAddresses.lastAddress {
                    // We're reading from palette memory and we return the fetched data immediately
                    // instead of delaying it by a cycle (but we do also populate the buffer as usual)
                    latchedValue = ppuDataBuffer
                }
            default:
                fatalError("Received impossible offset \(offset) in PPU.Registers")
            }
            
            // If we read a readable register, then latchedValue has that
            // register's value (from the switch above). If we read a non-
            // readable register, we return the previously latched value.
            return latchedValue
        }
        
        
    }
}

struct PPUAddressRegister {
    var rawValue : internal_ppu_address_register
    
    init(rawValue: internal_ppu_address_register) {
        self.rawValue = rawValue
    }
    
    init() {
        self.init(rawValue: .init(reg: 0))
    }
    
    /// Add this offset to 0x2000 (NES.PPUBusAddresses.nametable0Start) to get the correct tile
    var nametableAddressOffset: Address {
        return rawValue.reg & 0x0FFF    // The low 12 bits (everything except fineY)
    }
    
    /// Add this offset to 0x23C0 (NES.PPUBusAddresses.nametable0Start) to get the correct tile
    var attributeAddress: Address {
        let high3BitsOfCoarseX = Address(coarseXScroll >> 2)
        let high3BitsOfCoarseY = Address(coarseYScroll >> 2)
        
        // Build address like this, where NN is
        // nametableY followed by nametableX, and yyy
        // is the high 3 bits of coarseY, and xxx
        // is the high 3 bits of coarseX:
        //
        // 0000 NN 0000 yyy xxx
        return Address(nametableY ? 1 : 0) << 11 |
            Address(nametableX ? 1 : 0) << 10 |
            high3BitsOfCoarseY << 3 |
            high3BitsOfCoarseX
    }
    
    var coarseXScroll : UInt8 { // actually only 5 bits
        get { return Byte(rawValue.coarse_x) }
        set {
            assert(newValue < 0x20) // Ensure it fits in 5 bits
            rawValue.coarse_x = UInt16(newValue & 0x1F)
        }
    }
    
    var coarseYScroll : UInt8 { // actually only 5 bits
        get { return Byte(rawValue.coarse_y) }
        set {
            assert(newValue < 0x20) // Ensure it fits in 5 bits
            rawValue.coarse_y = UInt16(newValue & 0x1F)
        }
    }
    
    var nametableX : Bool {
        get { return rawValue.nametable_x == 1 }
        set { rawValue.nametable_x = newValue ? 1 : 0 }
    }
    
    var nametableY : Bool {
        get { return rawValue.nametable_y == 1 }
        set { rawValue.nametable_y = newValue ? 1 : 0 }
    }
    
    var fineYScroll : UInt8 {     // actually only 3 bits
        get { return UInt8(rawValue.fine_y) }
        set { assert(newValue < 0x8) // Ensure it fits in 3 bits
            rawValue.fine_y = UInt16(newValue & 0x7)
        }
    }
    
    mutating func incrementCoarseX() {
        if coarseXScroll == 31 {
            coarseXScroll = 0
            nametableX.toggle()
        } else {
            coarseXScroll += 1
        }
    }
    
    mutating func incrementFineY() {
        if fineYScroll < 7 {
            fineYScroll += 1
        } else {
            fineYScroll = 0
            
            if coarseYScroll == 29 {
                coarseYScroll = 0
                nametableY.toggle()
            } else if coarseYScroll == 31 { // Some weird bullshit: https://www.nesdev.org/wiki/PPU_scrolling#Y_increment
                coarseYScroll = 0
            } else {
                coarseYScroll += 1
            }
        }
    }
}
