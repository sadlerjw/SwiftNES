//
//  LDXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct LDXTests {
    let nes = NES(allRAM: true)
    let ldx = Instructions.LDX()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.x = 0x12
        cpu.fetchedData = 0x5D
        
        ldx.execute(cpu: cpu)
        
        #expect(cpu.x == 0x5D)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.x = 0x12
        cpu.fetchedData = 0x00
        
        ldx.execute(cpu: cpu)
        
        #expect(cpu.x == 0x00)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.x = 0x12
        cpu.fetchedData = 0x9C
        
        ldx.execute(cpu: cpu)
        
        #expect(cpu.x == 0x9C)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
