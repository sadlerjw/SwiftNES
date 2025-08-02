//
//  Registers.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//

extension PPU {
    class Registers : Addressable {
        struct PPUCTRL : OptionSet {    // Misc PPU settings
            let rawValue: Byte
            
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
            let rawValue: Byte
            
            static let greyscale = PPUCTRL(rawValue: 1 << 0)        // Force greyscale by ANDing colour with 0x30 to force them to use the grey column
            static let renderLeftBackgroundBorder = PPUCTRL(rawValue: 1 << 1)
            static let renderLeftSpritsBorder = PPUCTRL(rawValue: 1 << 2)
            static let renderBackground = PPUCTRL(rawValue: 1 << 3)
            static let renderSprites = PPUCTRL(rawValue: 1 << 4)
            static let emphasizeRed = PPUCTRL(rawValue: 1 << 5)     // https://www.nesdev.org/wiki/Colour_emphasis
            static let emphasizeGreen = PPUCTRL(rawValue: 1 << 6)
            static let emphasizeBlue = PPUCTRL(rawValue: 1 << 7)
        }
        
        struct PPUStatus : OptionSet {    // Rendering events
            let rawValue: Byte
            
            // Bits 0 through 4 are unused...
            
            // All 3 of these flags are cleared on dot 1 of the prerender scanline
            static let spriteOverflow = PPUCTRL(rawValue: 1 << 5)
            static let spriteZeroHit = PPUCTRL(rawValue: 1 << 6)
            static let vblank = PPUCTRL(rawValue: 1 << 7)   // Cleared on read
        }
        
        let length = 0x8
        let name: String = "PPU registers"
        unowned let ppu: PPU
        
        private var latchedValue : Byte = 0
        
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
                ppu.oamData = value
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
            case 3: // OAMADDR is write-only
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
    
    var fineY : UInt8 {     // actually only 3 bits
        get { return UInt8(rawValue.fine_y) }
        set { assert(newValue < 0x8) // Ensure it fits in 3 bits
            rawValue.fine_y = UInt16(newValue & 0x7)
        }
    }
}
