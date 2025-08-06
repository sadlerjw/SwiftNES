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
            if  oldValue.contains(.vblankNMI) && control.contains(.vblankNMI) {
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
    var scanline : Int = 261
    var cycle : Int = 0
    
    init(bus: Bus) {
        self.bus = bus
        self.actualRegisters = Registers(ppu: self)
    }
    
    private func swapFrameBuffers() {
        previousFrame = Data(currentFrameBuffer)
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
    
    func tick() {
        if (0 ..< 240).contains(scanline) {
            // Then this is a visible scanline

            if (1 ... 256).contains(cycle) {
                let pattern = renderingShiftRegisters.pattern(fineX: x)
                let paletteIndex = renderingShiftRegisters.palette(fineX: x)
                
                renderingShiftRegisters.shift()
                
                let rgba = getColorFromPalette(layer: .background, palette: paletteIndex, value: pattern)
                
                let pixel = cycle - 1
                
                currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 0] =  rgba[0]
                currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 1] =  rgba[1]
                currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 2] =  rgba[2]
                currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 3] =  rgba[3]
            }
        } else if scanline == 241 && cycle == 1 {
            status.insert(.vblank)
            swapFrameBuffers()
        }
        
        // TODO: check these numbers
        if cycle == 340 {
            cycle = 0
            
            if scanline == 261 {
                scanline = 0
                status.remove(.vblank) // TODO: this isn't the right place for this
                startR = Byte.random(in: 0...255)
                startG = Byte.random(in: 0...255)
                startB = Byte.random(in: 0...255)
            } else {
                scanline += 1
            }
        } else {
            cycle += 1
        }
    }
}
