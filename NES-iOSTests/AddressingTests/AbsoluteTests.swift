//
//  AbsoluteTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct AbsoluteTests {
    let nes = NES()
    let mode = AddressingModes.Absolute()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNoAdditionalCycles() {
        nes.ram.write(0x12, at: 0x01)
        nes.ram.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.ram.write(0xA9, at: 0xEE12)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xEE12)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCycles() {
        nes.ram.write(0x12, at: 0x01)
        nes.ram.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.ram.write(0xA9, at: 0xEE12)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xEE12)
        #expect(cpu.cyclesBeforeNextInstruction == 2)   // Can't cross page due to wraparound
    }
}
