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
    
    unowned let bus : Bus
    
    // Registers exposed on the main bus:
    var control = Registers.PPUCTRL() {
        didSet {
            if status.contains(.vblank) && !oldValue.contains(.vblankNMI) && control.contains(.vblankNMI) {
                // TODO: send NMI immediately
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
    
    init(bus: Bus) {
        self.bus = bus
        self.actualRegisters = Registers(ppu: self)
    }
    
    private func swapFrameBuffers() {
        previousFrame = Data(currentFrameBuffer)
    }
    
    private func patternTableAddress(leftTable: Bool, tile: Byte, highBitPlane: Bool) -> Address {
        let patternTableSelector : Address = leftTable ? (1 << 12) : 0
        let tileSelector : Address = Address(tile) << 4
        let bitPlaneSelector : Address = highBitPlane ? (1 << 3) : 0
        let fineYScroll = Address(t.fineYScroll)
        
        return patternTableSelector | tileSelector | bitPlaneSelector | fineYScroll
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
        let pattern = renderingShiftRegisters.pattern(fineX: x)
        let paletteIndex = renderingShiftRegisters.palette(fineX: x)
        
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
        if (0 ..< 240).contains(scanline) {
            // Then this is a visible scanline

            if (1 ... 256).contains(cycle) || (321 ... 336).contains(cycle) {
                renderingShiftRegisters.shift()
                
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
                    patternTableTileLow = bus.read(patternTableAddress(leftTable: !control.contains(.backgroundPatternTableAddress),
                                                                       tile: nametableByte,
                                                                       highBitPlane: true))
                    
                    v.incrementCoarseX()
                default:
                    break
                }
                
                if (1 ... 256).contains(cycle) {
                    renderPixel()
                    
                    if cycle >= 2 {
                        // TODO: sprite 0 hit detection
                    }
                }
            }
            
            if cycle == 257 || cycle == 337 {
                loadShiftRegiters()
            }
            
            if (257 ... 320).contains(cycle) {
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
            
            if cycle == 338 {
                // unused fetch from nametable
                let nametableAddress = NES.PPUBusAddresses.nametable0Start + v.nametableAddressOffset
                nametableByte = bus.read(nametableAddress)
            }
            if cycle == 340 {
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
                // TODO: send VBlank NMI
            }
        }
        
        if cycle == 256 {
            v.incrementFineY()
        } else if cycle == 257 {
            v.coarseXScroll = t.coarseXScroll
            v.nametableX = t.nametableX
        }
        
        // TODO: check these numbers
        
        if scanline == 261 && ( (isEvenFrame && cycle == 340) || (!isEvenFrame && cycle == 339) ) {
            cycle = 0
            scanline = 0
            isEvenFrame.toggle()
            status.remove(.vblank) // TODO: this isn't the right place for this
        } else if cycle == 340 {
            cycle = 0
            scanline += 1
        } else {
            cycle += 1
        }
    }
}
