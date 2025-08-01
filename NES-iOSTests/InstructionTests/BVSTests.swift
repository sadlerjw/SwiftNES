//
//  BNETests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct BVSTests {
    let nes = NES(allRAM: true)
    let bvs = Instructions.BVS()
    var cpu: CPU {
        return nes.cpu
    }
    @Test func testTaken() async throws {
        cpu.status.insert(.o)
        #expect(bvs.willBranch(cpu: cpu))
    }
    
    @Test func testNotTaken() async throws {
        cpu.status.remove(.o)
        #expect(!bvs.willBranch(cpu: cpu))
    }
}
