//
//  AbsoluteXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct AbsoluteXTests {
    let nes = NES(allRAM: true)
    let mode = AddressingModes.AbsoluteX()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNoAdditionalCyclesNoPageCrossed() {
        nes.mainBus.write(0x12, at: 0x01)
        nes.mainBus.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.x = 0x1B
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.mainBus.write(0xA9, at: 0xEE2D)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.pc == 0x03)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xEE2D)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCyclesNoPageCrossed() {
        nes.mainBus.write(0x12, at: 0x01)
        nes.mainBus.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.x = 0x1B
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.mainBus.write(0xA9, at: 0xEE2D)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.pc == 0x03)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xEE2D)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testNoAdditionalCyclesPageCrossed() {
        nes.mainBus.write(0x12, at: 0x01)
        nes.mainBus.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.x = 0xF3
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.mainBus.write(0xA9, at: 0xEF05)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.pc == 0x03)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xEF05)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCyclesPageCrossed() {
        nes.mainBus.write(0x12, at: 0x01)
        nes.mainBus.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.x = 0xF3
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        nes.mainBus.write(0xA9, at: 0xEF05)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.pc == 0x03)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xEF05)
        #expect(cpu.cyclesBeforeNextInstruction == 3)
    }
}
