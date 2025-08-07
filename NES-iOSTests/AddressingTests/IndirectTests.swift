//
//  IndirectTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct IndirectTests {
    let nes = NES(allRAM: true)
    let mode = AddressingModes.Indirect()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNoAdditionalCycles() {
        // Write the address of thee pointer to where the PC will be
        nes.mainBus.write(0x12, at: 0x01)
        nes.mainBus.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer's address
        nes.mainBus.write(0xDE, at: 0xEE12)
        nes.mainBus.write(0xDF, at: 0xEE13)
        
        // Write the value the pointer points to
        nes.mainBus.write(0xA9, at: 0xDFDE)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.pc == 0x03)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xDFDE)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCycles() {
        // Write the address of thee pointer to where the PC will be
        nes.mainBus.write(0x12, at: 0x01)
        nes.mainBus.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer's address
        nes.mainBus.write(0xDE, at: 0xEE12)
        nes.mainBus.write(0xDF, at: 0xEE13)
        
        // Write the value the pointer points to
        nes.mainBus.write(0xA9, at: 0xDFDE)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.pc == 0x03)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0xDFDE)
        #expect(cpu.cyclesBeforeNextInstruction == 2)   // Can't cross page due to wraparound
    }
    
    @Test func testWraparoundBug() {
        // If the low byte of the pointer is in address 0x??FF,
        // then instead of reading the high byte from the next
        // sequential address, which would be in a different page,
        // there's a hardware bug where the high byte comes from
        // the zeroth offset of the _same_ page, 0x??00.
        
        // Write the address of the pointer to where the PC will be
        nes.mainBus.write(0xFF, at: 0x01)
        nes.mainBus.write(0xEE, at: 0x02)
        cpu.pc = 0x01
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer's address
        nes.mainBus.write(0x34, at: 0xEEFF)
        nes.mainBus.write(0xAA, at: 0xEF00)
        nes.mainBus.write(0x12, at: 0xEE00)
        
        // Write the value the pointer points to
        nes.mainBus.write(0xA9, at: 0x1234)
        
        // Write a different value to where the pointer _should_ have pointed to
        nes.mainBus.write(0xCC, at: 0xAA34)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.pc == 0x03)
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.fetchedFromAddress == 0x1234)
        #expect(cpu.cyclesBeforeNextInstruction == 2)   // Can't cross page due to wraparound
    }
}
