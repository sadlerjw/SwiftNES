//
//  LDATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct STATests {
    let nes = NES()
    let sta = Instructions.STA()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.fetchedFromAddress = 0x1234
        cpu.a = 0xF3
        
        sta.execute(cpu: cpu)
        
        #expect(cpu.bus.read(0x1234) == 0xF3)
    }
}
