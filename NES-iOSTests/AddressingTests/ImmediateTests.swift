//
//  ImmediateTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct ImmediateTests {
    let nes = NES()
    let mode = AddressingModes.Immediate()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoAdditionalCycles() {
        nes.ram.write(0xA9, at: 0x00)
        cpu.pc = 0x00
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCycles() {
        nes.ram.write(0xA9, at: 0x00)
        cpu.pc = 0x00
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }

}
