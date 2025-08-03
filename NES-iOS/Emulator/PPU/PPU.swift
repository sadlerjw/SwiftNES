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
    
    init(bus: Bus) {
        self.bus = bus
        self.actualRegisters = Registers(ppu: self)
    }
}
