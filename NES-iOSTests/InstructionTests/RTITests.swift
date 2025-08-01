//
//  ANDTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct RTITests {
    let nes = NES(allRAM: true)
    let rti = Instructions.RTI()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoB() async throws {
        nes.startup()
        cpu.stack.push(Address(0x1234))
        cpu.stack.push(CPU.StatusRegister(arrayLiteral: [.c, .n, .z]).rawValue)
        
        rti.execute(cpu: cpu)
        
        #expect(cpu.status == [.c, .n, .z, .one_unused])
        #expect(cpu.pc == 0x1234)
        #expect(!cpu.changingInterruptsEnabledShouldBeDelayed)
    }
    
    @Test func testB() async throws {
        nes.startup()
        cpu.stack.push(Address(0x1234))
        cpu.stack.push(CPU.StatusRegister(arrayLiteral: [.n, .b]).rawValue)
        
        rti.execute(cpu: cpu)
        
        #expect(cpu.status == [.n, .one_unused])
        #expect(cpu.pc == 0x1234)
        #expect(!cpu.changingInterruptsEnabledShouldBeDelayed)
    }
}
