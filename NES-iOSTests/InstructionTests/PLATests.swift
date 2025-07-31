//
//  ANDTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct PLATests {
    let nes = NES()
    let pla = Instructions.PLA()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func test() async throws {
        nes.startup()
        cpu.stack.push(Byte(0xF3))
        
        let stackPointer = cpu.stack.stackPointer
        
        pla.execute(cpu: cpu)
        
        #expect(cpu.a == 0xF3)
        #expect(stackPointer != cpu.stack.stackPointer)
    }
}
