//
//  AccumulatorTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct AccumulatorTests {
    let nes = NES(allRAM: true)
    let mode = AddressingModes.Accumulator()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoAdditionalCycles() {
        cpu.a = 0xA9
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == nil)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCycles() {
        cpu.a = 0xA9
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == nil)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
}
