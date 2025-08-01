//
//  CLCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct SEDTests {
    let nes = NES()
    let sed = Instructions.SED()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.status.remove(.d)
        
        sed.execute(cpu: cpu)
        
        #expect(cpu.status.contains(.d))
    }

}
