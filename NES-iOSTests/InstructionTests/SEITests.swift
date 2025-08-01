//
//  CLCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct SEITests {
    let nes = NES(allRAM: true)
    let sei = Instructions.SEI()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.status.remove(.i)
        
        sei.execute(cpu: cpu)
        
        #expect(cpu.status.contains(.i))
        #expect(cpu.changingInterruptsEnabledShouldBeDelayed)
    }

}
