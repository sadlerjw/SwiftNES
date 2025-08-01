//
//  LDATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct STYTests {
    let nes = NES()
    let sty = Instructions.STY()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.fetchedFromAddress = 0x1234
        cpu.y = 0xF3
        
        sty.execute(cpu: cpu)
        
        #expect(cpu.bus.read(0x1234) == 0xF3)
    }
}
