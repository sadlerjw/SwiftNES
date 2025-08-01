//
//  BNETests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct BPLTests {
    let nes = NES(allRAM: true)
    let bpl = Instructions.BPL()
    var cpu: CPU {
        return nes.cpu
    }
    @Test func testTaken() async throws {
        cpu.status.remove(.n)
        #expect(bpl.willBranch(cpu: cpu))
    }
    
    @Test func testNotTaken() async throws {
        cpu.status.insert(.n)
        #expect(!bpl.willBranch(cpu: cpu))
    }
}
