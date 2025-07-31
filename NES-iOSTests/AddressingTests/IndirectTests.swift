//
//  IndirectTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct IndirectTests {
    let nes = NES()
    let mode = AddressingModes.Indirect()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNoAdditionalCycles() {
        // Write the address of thee pointer to where the PC will be
        nes.ram.write(0x12, at: 0x01)
        nes.ram.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer's address
        nes.ram.write(0xDE, at: 0xEE12)
        nes.ram.write(0xDF, at: 0xEE13)
        
        // Write the value the pointer points to
        nes.ram.write(0xA9, at: 0xDFDE)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xDFDE)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCycles() {
        // Write the address of thee pointer to where the PC will be
        nes.ram.write(0x12, at: 0x01)
        nes.ram.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer's address
        nes.ram.write(0xDE, at: 0xEE12)
        nes.ram.write(0xDF, at: 0xEE13)
        
        // Write the value the pointer points to
        nes.ram.write(0xA9, at: 0xDFDE)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xDFDE)
        #expect(cpu.cyclesBeforeNextInstruction == 2)   // Can't cross page due to wraparound
    }
}
