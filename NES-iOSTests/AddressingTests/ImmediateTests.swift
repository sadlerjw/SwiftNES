//
//  ImmediateTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct ImmediateTests {
    let nes = NES(allRAM: true)
    let mode = AddressingModes.Immediate()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoAdditionalCycles() {
        nes.mainBus.write(0xA9, at: 0x01)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.pc == 0x02)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0x01)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCycles() {
        nes.mainBus.write(0xA9, at: 0x01)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.pc == 0x02)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0x01)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
}
