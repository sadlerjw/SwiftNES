//
//  PPU.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-01.
//

import Foundation

class PPU {
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
    
    // Internals:
    var oam = OAMTable()
    
    // Internal scrolling registers (https://www.nesdev.org/wiki/PPU_scrolling#PPU_internal_registers)
    var v = PPUAddressRegister()    // Current VRAM address (15 bits)
    var t = PPUAddressRegister()    // Temporary VRAM address, used as address of the top left onscreen tile (15 bits)
    var x: Byte = 0     // Fine x scroll (3 bits)
    var w: Bool = false // First or second write toggle
    
    let bytesPerPixel = 4
    private(set) var previousFrame = Data(repeating: 0, count: 245760)         // 256x240x4 (RGBA)
    private(set) var currentFrameBuffer = Data(repeating: 0, count: 245760)
    
    private(set) var isEvenFrame = true
    var scanline : Int = 261
    var cycle : Int = 0
    
    init(bus: Bus) {
        self.bus = bus
        self.actualRegisters = Registers(ppu: self)
    }
    
    private func swapFrameBuffers() {
        let temp = previousFrame
        previousFrame = currentFrameBuffer
        currentFrameBuffer = temp
    }
    
    func tick() {
        if (0 ..< 240).contains(scanline) {
            // Then this is a visible scanline
            if (1 ... 256).contains(cycle) {
                let r = UInt8.random(in: 0 ... 255)
                let g = UInt8.random(in: 0 ... 255)
                let b = UInt8.random(in: 0 ... 255)
                let a = UInt8(0xFF)
                
                let pixel = cycle - 1
                
                currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 0] =  r
                currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 1] =  g
                currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 2] =  b
                currentFrameBuffer[scanline * 256 * bytesPerPixel + pixel * bytesPerPixel + 3] =  a
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
            } else {
                scanline += 1
            }
        } else {
            cycle += 1
        }
    }
}
