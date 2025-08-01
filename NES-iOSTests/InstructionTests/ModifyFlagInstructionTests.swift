//
//  ModifyFlagInstructionTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-31.
//

import Testing
@testable import NES_iOS

struct MockModifyFlagInstruction : ModifyFlagInstruction {
    static let sharedInstance = Self.init(set: true, flag: [])
    
    static let opcodeReferences : [OpcodeReference] = []
    
    var set : Bool
    var flag : CPU.StatusRegister
}

@MainActor struct ModifyFlagInstructionTests {
    let nes = NES(allRAM: true)
    let clc = Instructions.CLC()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testSet() async throws {
        cpu.status.remove(.c)
        
        MockModifyFlagInstruction(set: true, flag: .c).execute(cpu: cpu)
        
        #expect(cpu.status.contains(.c))
    }
    
    @Test func testClear() async throws {
        cpu.status.remove(.d)
        
        MockModifyFlagInstruction(set: false, flag: .d).execute(cpu: cpu)
        
        #expect(!cpu.status.contains(.d))
    }

}
