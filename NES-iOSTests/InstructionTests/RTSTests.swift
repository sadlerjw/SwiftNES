//
//  ANDTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct RTSTests {
    let nes = NES()
    let rts = Instructions.RTS()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoB() async throws {
        nes.startup()
        cpu.stack.push(Address(0x1234))
        
        rts.execute(cpu: cpu)

        #expect(cpu.pc == 0x1235)
    }
}
