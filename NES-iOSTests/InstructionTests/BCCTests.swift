//
//  BCCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct BCCTests {
    let nes = NES()
    let bcc = Instructions.BCC()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testTaken() async throws {
        cpu.status.remove(.c)
        #expect(bcc.willBranch(cpu: cpu))
    }
    
    @Test func testNotTaken() async throws {
        cpu.status.insert(.c)
        #expect(!bcc.willBranch(cpu: cpu))
    }
}
