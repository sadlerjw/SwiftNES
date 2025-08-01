//
//  CLCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct CLITests {
    let nes = NES(allRAM: true)
    let cli = Instructions.CLI()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.status.insert(.i)
        
        cli.execute(cpu: cpu)
        
        #expect(!cpu.status.contains(.i))
    }

}
