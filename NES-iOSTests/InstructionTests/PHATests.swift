//
//  ANDTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct PHATests {
    let nes = NES(allRAM: true)
    let pha = Instructions.PHA()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func test() async throws {
        nes.startup()
        cpu.a = 0xF3
        
        pha.execute(cpu: cpu)
        
        #expect(cpu.stack.popByte() == 0xF3)
    }
}
