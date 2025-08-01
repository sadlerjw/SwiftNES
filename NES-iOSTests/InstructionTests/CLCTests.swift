//
//  CLCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct CLCTests {
    let nes = NES(allRAM: true)
    let clc = Instructions.CLC()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.status.insert(.c)
        
        clc.execute(cpu: cpu)
        
        #expect(!cpu.status.contains(.c))
    }

}
