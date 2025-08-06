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

        cpu.fetchedData = 0x34
        cpu.fetchedFromAddress = 0x1234

        jsr.execute(cpu: cpu)
        
        #expect(cpu.pc == 0x1234)
        #expect(cpu.stack.popAddress() == 0xABCD)
    }

}
