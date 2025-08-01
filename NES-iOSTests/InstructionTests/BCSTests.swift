//
//  BCSTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct BCSTests {
    let nes = NES(allRAM: true)
    let bcs = Instructions.BCS()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testTaken() async throws {
        cpu.status.insert(.c)
        #expect(bcs.willBranch(cpu: cpu))
    }
    
    @Test func testNotTaken() async throws {
        cpu.status.remove(.c)
        #expect(!bcs.willBranch(cpu: cpu))
    }
}
