//
//  PPU.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-01.
//

import Foundation

class PPU {
    enum Layer {
        case background
        case sprite
    }
    
    unowned let bus : any BusProtocol
    unowned let cpu : CPU
    
    // Registers exposed on the main bus:
    var control = Registers.PPUCTRL() {
        didSet {
            if status.contains(.vblank) && !oldValue.contains(.vblankNMI) && control.contains(.vblankNMI) {
                cpu.nmi()
            }
            t.nametableX = control.contains(.nametableX)
            t.nametableY = control.contains(.nametableY)
        }
    }
    
    var mask = Registers.PPUMASK()
    
    var status = Registers.PPUStatus()
    
    var oamAddress : Byte = 0    // TODO: set to 0 during each of ticks 257-320 of pre-render and visible scanlines
    
    private var actualRegisters : Registers!
    var addressableRegisters : Registers { actualRegisters }
    
    private(set) var renderingShiftRegisters = RenderingShiftRegisters()
    
    // Internals:
    var oam = OAMTable()
    
    // Internal scrolling registers (https://www.nesdev.org/wiki/PPU_scrolling#PPU_internal_registers)
    var v = PPUAddressRegister()    // Current VRAM address (15 bits)
    var t = PPUAddressRegister()    // Temporary VRAM address, used as address of the top left onscreen tile (15 bits)
    var x: Byte = 0     // Fine x scroll (3 bits)
    var w: Bool = false // First or second write toggle
    
    let bytesPerPixel = 4
    private(set) var previousFrame = Data(repeating: 0, count: 245760)         // 256x240x4 (RGBA)
    private(set) var currentFrameBuffer = Array(repeating: Byte(0), count: 245760) //= Data(repeating: 0, count: 245760)
    
    private(set) var isEvenFrame = true
    private(set) var scanline : Int = 261
    private(set) var cycle : Int = 0
    
    private(set) var nametableByte: Byte = 0
    private(set) var attributeTableByte: Byte = 0
    private(set) var patternTableTileLow: Byte = 0
    private(set) var patternTableTileHigh: Byte = 0
    
    var isRenderingEnabled : Bool {
        return mask.contains(.renderBackground) || mask.contains(.renderSprites)
    }
    
    init(bus: any BusProtocol, cpu: CPU) {
        self.bus = bus
        self.cpu = cpu
        self.actualRegisters = Registers(ppu: self)
    }
    
    func startup() {
        reset()
        status.remove(.spriteZeroHit)
        status.insert(.vblank)
        status.insert(.spriteOverflow)
        oamAddress = 0
    }
    
    func reset() {
        control.rawValue = 0
        mask.rawValue = 0
        w = false
        actualRegisters.ppuDataBuffer = 0
        isEvenFrame = true
        t.rawValue.reg = 0
        x = 0
    }
    
    private func swapFrameBuffers() {
        previousFrame = Data(currentFrameBuffer)
    }
    
    private func patternTableAddress(leftTable: Bool, tile: Byte, highBitPlane: Bool) -> Address {
        let patternTableSelector : Address = leftTable ? 0 : (1 << 12)
        let tileSelector : Address = Address(tile) << 4
        let bitPlaneSelector : Address = highBitPlane ? (1 << 3) : 0
        let fineYScroll = Address(v.fineYScroll)
        
        let address = patternTableSelector | tileSelector | bitPlaneSelector | fineYScroll
        
        return address
    }
    
    /// Returns an RGBA array
    private func getColorFromPalette(layer: Layer, palette: Byte, value: Byte) -> [Byte] {
        guard palette < 4 else { fatalError("Invalid palette index: \(palette)") }
        guard value < 4 else { fatalError("Invalid palette value: \(value)") }
        
        let nesColor : Byte
        
        if value == 0 {
            nesColor = bus.read(0x3F00)
        } else {
            
            let paletteBaseAddress : Address
            switch layer {
            case .background:
                paletteBaseAddress = 0x3F00
            case .sprite:
                paletteBaseAddress = 0x3F10
            }
            
            nesColor = bus.read(paletteBaseAddress + Address(palette) * 4 + Address(value))
        }
        
        let rgba = Color.colors[Int(nesColor)]
        
        // TODO: color tint bits: https://www.nesdev.org/wiki/NTSC_video#Color_Tint_Bits
        
        return rgba
    }
    
    func renderPixel() {
        let pattern: Byte
        let paletteIndex: Byte
        
        if isRenderingEnabled {
            pattern = renderingShiftRegisters.pattern(fineX: x)
            paletteIndex = renderingShiftRegisters.palette(fineX: x)
        } else {
            if v.rawValue.reg >= NES.PPUBusAddresses.paletteRAMIndexesStart {
                // When v is interpreted as an address and it points into palette RAM,
                // draw that colour.
                // Since there are 4 colours per palette, we choose the palette by dividing
                // the offset by 4 (rounding down) and index within the palette by pattern,
                // which must be the remainder.
                let paletteAddress = Byte(v.rawValue.reg - NES.PPUBusAddresses.paletteRAMIndexesStart)
                pattern = paletteAddress % 4
                paletteIndex = paletteAddress / 4
            } else {
                pattern = 0
                paletteIndex = 0
            }
        }
        
        let rgba = getColorFromPalette(layer: .background, palette: paletteIndex, value: pattern)
        
        let pixel = cycle - 1
        
        currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 0] =  rgba[0]
        currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 1] =  rgba[1]
        currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 2] =  rgba[2]
        currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 3] =  rgba[3]
    }
    
    private func loadShiftRegiters() {
        // Set renderingShiftRegisters
        renderingShiftRegisters.loadPattern(high: patternTableTileHigh, low: patternTableTileLow)
        
        // Now to select the correct 2 bits from the attribute byte.
        // We break the tile we've loaded the pattern for into 4 quadrants,
        // with two of the attribute byte's bits corresponding to each
        // quadrant like so:
        // +-----+-----+
        // | 1 0 | 3 2 |
        // +-----+-----+
        // | 5 4 | 7 6 |
        // +-----+-----+
        if v.coarseYScroll % 4 > 2 {
            // Top row
            if v.coarseXScroll % 4 < 2 {
                // Top left - take bytes 0 and 1
                renderingShiftRegisters.loadAttributes(high: (attributeTableByte & 1 << 0) > 0,
                                                       low: (attributeTableByte & 1 << 1) > 0)
            } else {
                // Top right - take bytes 2 and 3
                renderingShiftRegisters.loadAttributes(high: (attributeTableByte & 1 << 2) > 0,
                                                       low: (attributeTableByte & 1 << 3) > 0)
            }
        } else {
            if v.coarseXScroll % 4 < 2 {
                // Bottom left - take bytes 4 and 5
                renderingShiftRegisters.loadAttributes(high: (attributeTableByte & 1 << 5) > 0,
                                                       low: (attributeTableByte & 1 << 4) > 0)
            } else {
                // Bottom right - take bytes 6 and 7
                renderingShiftRegisters.loadAttributes(high: (attributeTableByte & 1 << 7) > 0,
                                                       low: (attributeTableByte & 1 << 6) > 0)
            }
        }
    }
    
    func tick() {
        if scanline == 0 && cycle == 0 && !isEvenFrame && isRenderingEnabled {
            // Skip one cycle on odd frames
            cycle = 1
        }
        
        if (0 ..< 240).contains(scanline) {
            // Then this is a visible scanline

            if (1 ... 256).contains(cycle) || (321 ... 336).contains(cycle) {
                renderingShiftRegisters.shift()
                
                if isRenderingEnabled {
                    switch cycle % 8 {
                    case 1:
                        // Loading the shift registers happens starting on cycle 9
                        if cycle != 1 && cycle != 321 {
                            loadShiftRegiters()
                        }
                    case 2:
                        // fetch from nametable
                        let nametableAddress = NES.PPUBusAddresses.nametable0Start + v.nametableAddressOffset
                        nametableByte = bus.read(nametableAddress)
                    case 4:
                        let attributeAddress = NES.PPUBusAddresses.attributeTable0Start + v.attributeAddress
                        attributeTableByte = bus.read(attributeAddress)
                    case 6:
                        patternTableTileLow = bus.read(patternTableAddress(leftTable: !control.contains(.backgroundPatternTableAddress),
                                                                           tile: nametableByte,
                                                                           highBitPlane: false))
                    case 0:
                        patternTableTileHigh = bus.read(patternTableAddress(leftTable: !control.contains(.backgroundPatternTableAddress),
                                                                            tile: nametableByte,
                                                                            highBitPlane: true))
                        
                        v.incrementCoarseX()
                    default:
                        break
                    }
                }
                
                if (1 ... 256).contains(cycle) {
                    renderPixel()
                    
                    if cycle >= 2 && isRenderingEnabled {
                        // TODO: sprite 0 hit detection
                    }
                }
            }
            
            if isRenderingEnabled && (cycle == 257 || cycle == 337) {
                loadShiftRegiters()
            }
            
            if isRenderingEnabled && (257 ... 320).contains(cycle) {
                // TODO: Load tile data for sprites for next scanline
                if cycle % 8 == 2 {
                    // unused fetch from nametable
                    let nametableAddress = NES.PPUBusAddresses.nametable0Start + v.nametableAddressOffset
                    nametableByte = bus.read(nametableAddress)
                }
                if cycle % 8 == 4 {
                    // ignored fetch from nametable
                    let nametableAddress = NES.PPUBusAddresses.nametable0Start + v.nametableAddressOffset
                    _ = bus.read(nametableAddress)
                }
            }
            
            if isRenderingEnabled && cycle == 338 {
                // unused fetch from nametable
                let nametableAddress = NES.PPUBusAddresses.nametable0Start + v.nametableAddressOffset
                nametableByte = bus.read(nametableAddress)
            }
            if isRenderingEnabled && cycle == 340 {
                // ignored fetch from nametable
                let nametableAddress = NES.PPUBusAddresses.nametable0Start + v.nametableAddressOffset
                _ = bus.read(nametableAddress)
            }
        }
        
        if scanline == 240 && cycle == 0 {
            swapFrameBuffers()
        }
        
        if scanline == 241 && cycle == 1 {
            status.insert(.vblank)
            if control.contains(.vblankNMI) {
                cpu.nmi()
            }
        }
        
        if cycle == 256 && isRenderingEnabled {
            v.incrementFineY()
        } else if cycle == 257 && isRenderingEnabled {
            v.coarseXScroll = t.coarseXScroll
            v.nametableX = t.nametableX
        }
        
        // TODO: check these numbers
        
        if scanline == 261 {
            if cycle == 1 {
                status.remove(.vblank)
                status.remove(.spriteOverflow)
                status.remove(.spriteZeroHit)
            }
            
            if cycle > 280 && cycle < 305 && isRenderingEnabled {
                // https://www.nesdev.org/wiki/PPU_scrolling#During_dots_280_to_304_of_the_pre-render_scanline_(end_of_vblank)
                v.fineYScroll = t.fineYScroll
                v.nametableY = t.nametableY
                v.coarseYScroll = t.coarseYScroll
            }
            
            if cycle == 340 {
                cycle = 0
                scanline = 0
                isEvenFrame.toggle()
            } else {
                cycle += 1
            }
            
        } else if cycle == 340 {
            cycle = 0
            scanline += 1
        } else {
            cycle += 1
        }
    }
}
