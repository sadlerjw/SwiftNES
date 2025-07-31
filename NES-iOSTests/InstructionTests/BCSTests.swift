//
//  BCSTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct BCSTests {
    let nes = NES()
    let bcs = Instructions.BCS()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testBackwardsTaken() async throws {
        cpu.status.insert(.c)
        cpu.pc = 0x100F
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = UInt8(bitPattern: -5)
        
        bcs.execute(cpu: cpu)
        
        #expect(cpu.pc == 0x100A)
        #expect(cpu.cyclesBeforeNextInstruction == 3)
    }
    
    @Test func testBackwardsNotTaken() async throws {
        cpu.status.remove(.c)
        cpu.pc = 0x1002
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = UInt8(bitPattern: -5)
        
        bcs.execute(cpu: cpu)
        
        #expect(cpu.pc == 0x1002)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testForwardsTaken() async throws {
        cpu.status.insert(.c)
        cpu.pc = 0x1002
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 14
        
        bcs.execute(cpu: cpu)
        
        #expect(cpu.pc == 0x1010)
        #expect(cpu.cyclesBeforeNextInstruction == 3)
    }
    
    @Test func testForwardsNotTaken() async throws {
        cpu.status.remove(.c)
        cpu.pc = 0x1002
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 14
        
        bcs.execute(cpu: cpu)
        
        #expect(cpu.pc == 0x1002)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testBackwardsTakenAcrossPageBoundary() async throws {
        cpu.status.insert(.c)
        cpu.pc = 0x1002
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = UInt8(bitPattern: -5)
        
        bcs.execute(cpu: cpu)
        
        #expect(cpu.pc == 0x0FFD)
        #expect(cpu.cyclesBeforeNextInstruction == 4)
    }

}
