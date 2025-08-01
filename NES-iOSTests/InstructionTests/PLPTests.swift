//
//  ANDTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct PLPTests {
    let nes = NES(allRAM: true)
    let plp = Instructions.PLP()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoB() async throws {
        nes.startup()
        cpu.stack.push(CPU.StatusRegister(arrayLiteral: [.c, .n, .z]).rawValue)
        
        plp.execute(cpu: cpu)
        
        #expect(cpu.status == [.c, .n, .z, .one_unused])
        #expect(cpu.changingInterruptsEnabledShouldBeDelayed)
    }
    
    @Test func testB() async throws {
        nes.startup()
        cpu.stack.push(CPU.StatusRegister(arrayLiteral: [.n, .b]).rawValue)
        
        plp.execute(cpu: cpu)
        
        #expect(cpu.status == [.n, .one_unused])
        #expect(cpu.changingInterruptsEnabledShouldBeDelayed)
    }
}
