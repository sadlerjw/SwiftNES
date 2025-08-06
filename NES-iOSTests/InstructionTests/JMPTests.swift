//
//  LDATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct JMPTests {
    let nes = NES(allRAM: true)
    let jmp = Instructions.JMP()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.fetchedData = 0x34
        cpu.fetchedFromAddress = 0xFF00
        
        jmp.execute(cpu: cpu)
        
        #expect(cpu.pc == 0xFF00)
    }
}
