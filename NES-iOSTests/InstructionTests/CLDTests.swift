//
//  CLCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct CLDTests {
    let nes = NES()
    let cld = Instructions.CLD()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.status.insert(.d)
        
        cld.execute(cpu: cpu)
        
        #expect(!cpu.status.contains(.d))
    }

}
