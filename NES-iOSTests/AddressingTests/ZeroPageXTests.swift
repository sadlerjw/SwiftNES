//
//  ZeroPageXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct ZeroPageXTests {
    let nes = NES(allRAM: true)
    let mode = AddressingModes.ZeroPageX()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNoAdditionalCycles() {
        nes.mainBus.write(0xEE, at: 0x01)
        cpu.pc = 0x01
        cpu.x = 0x04
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.mainBus.write(0xA9, at: 0xF2)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xF2)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCycles() {
        nes.mainBus.write(0xEE, at: 0x01)
        cpu.pc = 0x01
        cpu.x = 0x04
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.mainBus.write(0xA9, at: 0xF2)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xF2)
        #expect(cpu.cyclesBeforeNextInstruction == 2)   // Can't cross page due to wraparound
    }
    
    @Test func testWrappingAround() {
        nes.mainBus.write(0xEE, at: 0x01)
        cpu.pc = 0x01
        cpu.x = 0x1F
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.mainBus.write(0xA9, at: 0x0D)
        nes.mainBus.write(0x12, at: 0x1D)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0x0D)
        #expect(cpu.cyclesBeforeNextInstruction == 2) // We haven't crossed pages - we've wrapped around to the start of the zero page
    }
}
