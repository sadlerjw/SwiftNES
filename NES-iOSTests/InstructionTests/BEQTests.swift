//
//  BNETests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct BEQTests {
    let nes = NES()
    let beq = Instructions.BEQ()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testTaken() async throws {
        cpu.status.insert(.z)
        #expect(beq.willBranch(cpu: cpu))
    }
    
    @Test func testNotTaken() async throws {
        cpu.status.remove(.z)
        #expect(!beq.willBranch(cpu: cpu))
    }
}
