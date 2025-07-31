//
//  BranchInstructionTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

struct MockBranchInstruction : BranchInstruction {
    static var sharedInstance = MockBranchInstruction(willBranch: false)
    
    static var opcodeReferences = [OpcodeReference]()
    
    var willBranch : Bool
    
    func willBranch(cpu: CPU) -> Bool {
        return willBranch
    }
}

@MainActor struct BranchInstructionTests {
    let nes = NES()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testBackwardsTaken() async throws {
        cpu.pc = 0x100F
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = UInt8(bitPattern: -5)
        
        MockBranchInstruction(willBranch: true).execute(cpu: cpu)
        
        #expect(cpu.pc == 0x100A)
        #expect(cpu.cyclesBeforeNextInstruction == 3)
    }
    
    @Test func testBackwardsNotTaken() async throws {
        cpu.pc = 0x1002
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = UInt8(bitPattern: -5)
        
        MockBranchInstruction(willBranch: false).execute(cpu: cpu)
        
        #expect(cpu.pc == 0x1002)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testForwardsTaken() async throws {
        cpu.pc = 0x1002
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 14
        
        MockBranchInstruction(willBranch: true).execute(cpu: cpu)
        
        #expect(cpu.pc == 0x1010)
        #expect(cpu.cyclesBeforeNextInstruction == 3)
    }
    
    @Test func testForwardsNotTaken() async throws {
        cpu.pc = 0x1002
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = 14
        
        MockBranchInstruction(willBranch: false).execute(cpu: cpu)
        
        #expect(cpu.pc == 0x1002)
        #expect(cpu.cyclesBeforeNextInstruction == 2)
    }
    
    @Test func testBackwardsTakenAcrossPageBoundary() async throws {
        cpu.pc = 0x1002
        cpu.cyclesBeforeNextInstruction = 2
        cpu.fetchedData = UInt8(bitPattern: -5)
        
        MockBranchInstruction(willBranch: true).execute(cpu: cpu)
        
        #expect(cpu.pc == 0x0FFD)
        #expect(cpu.cyclesBeforeNextInstruction == 4)
    }

}
