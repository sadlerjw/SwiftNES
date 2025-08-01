//
//  BRKTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-31.
//

import Testing
@testable import NES_iOS

@MainActor struct JSRTests {
    let nes = NES(allRAM: true)
    let jsr = Instructions.JSR()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        nes.startup()
        cpu.pc = 0xABCD
        cpu.pc += 1
        
        // Set the jump destination to 0x1234
        cpu.bus.write(0x34, at: cpu.pc)
        cpu.bus.write(0x12, at: cpu.pc + 1)
        
        cpu.fetchedData = 0x34
        cpu.fetchedFromAddress = cpu.pc

        jsr.execute(cpu: cpu)
        
        #expect(cpu.pc == 0x1234)
        #expect(cpu.stack.popAddress() == 0xABCD + 2)
    }

}
