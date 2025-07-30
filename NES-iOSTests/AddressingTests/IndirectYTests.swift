//
//  IndirectYTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct IndirectYTests {
    let nes = NES()
    let mode = AddressingModes.IndirectY()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoAdditionalCyclesNoPageBreak() {
        // Write the address of the zero-page pointer at the PC
        nes.ram.write(0xE0, at: 0x01)
        cpu.pc = 0x01
        cpu.y = 0x04
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer that we'll access
        nes.ram.write(0xCD, at: 0xE0)
        nes.ram.write(0xAB, at: 0xE1)
        
        // Write the value that the above pointer points to
        nes.ram.write(0xA9, at: 0xABD1)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCyclesNoPageBreak() {
        // Write the address of the zero-page pointer at the PC
        nes.ram.write(0xE0, at: 0x01)
        cpu.pc = 0x01
        cpu.y = 0x04
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer that we'll access
        nes.ram.write(0xCD, at: 0xE0)
        nes.ram.write(0xAB, at: 0xE1)
        
        // Write the value that the above pointer points to
        nes.ram.write(0xA9, at: 0xABD1)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testNoAdditionalCyclesWithPageBreak() {
        // Write the address of the zero-page pointer at the PC
        nes.ram.write(0xE0, at: 0x01)
        cpu.pc = 0x01
        cpu.y = 0x45
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer that we'll access
        nes.ram.write(0xCD, at: 0xE0)
        nes.ram.write(0xAB, at: 0xE1)
        
        // Write the value that the above pointer points to
        nes.ram.write(0xA9, at: 0xAC12)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: false)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testAdditionalCyclesWithPageBreak() {
        // Write the address of the zero-page pointer at the PC
        nes.ram.write(0xE0, at: 0x01)
        cpu.pc = 0x01
        cpu.y = 0x45
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 0x00
        
        // Write the pointer that we'll access
        nes.ram.write(0xCD, at: 0xE0)
        nes.ram.write(0xAB, at: 0xE1)
        
        // Write the value that the above pointer points to
        nes.ram.write(0xA9, at: 0xAC12)
        
        mode.fetch(cpu: cpu, addingCycleIfPageCrossed: true)
        
        #expect(cpu.fetchedData == 0xA9)
        #expect(cpu.cyclesBeforeNextInstruction == 3)
    }
}

