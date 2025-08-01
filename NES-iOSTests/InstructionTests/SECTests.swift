//
//  CLCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct SECTests {
    let nes = NES(allRAM: true)
    let sec = Instructions.SEC()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.status.remove(.c)
        
        sec.execute(cpu: cpu)
        
        #expect(cpu.status.contains(.c))
    }

}
