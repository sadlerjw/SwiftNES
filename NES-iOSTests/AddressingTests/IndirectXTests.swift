//
//  IndirectXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct IndirectXTests {
    let nes = NES(allRAM: true)
    let mode = AddressingModes.IndirectX()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoAdditionalCycles() {
        // Write the base address of the table of pointers at the PC
        nes.mainBus.write(0xE0, at: 0x01)
        cpu.pc = 0x01
        cpu.x = 0x04
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer that we'll access in the table of pointers
        nes.mainBus.write(0xCD, at: 0xE4)
        nes.mainBus.write(0xAB, at: 0xE5)
        
        // Write the value that the above pointer points to
        nes.mainBus.write(0xA9, at: 0xABCD)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xABCD)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCycles() {
        // Write the base address of the table of pointers at the PC
        nes.mainBus.write(0xE0, at: 0x01)
        cpu.pc = 0x01
        cpu.x = 0x04
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer that we'll access in the table of pointers
        nes.mainBus.write(0xCD, at: 0xE4)
        nes.mainBus.write(0xAB, at: 0xE5)
        
        // Write the value that the above pointer points to
        nes.mainBus.write(0xA9, at: 0xABCD)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xABCD)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
}
