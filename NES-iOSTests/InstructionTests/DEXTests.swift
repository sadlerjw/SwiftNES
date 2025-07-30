//
//  DEXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct DEXTests {
    let nes = NES()
    let dex = Instructions.DEX()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.x = 0x1A
        
        dex.execute(cpu: cpu)
        
        #expect(cpu.x == 0x19)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.x = 0x01
        
        dex.execute(cpu: cpu)
        
        #expect(cpu.x == 0x00)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }

    @Test func testNegativeFromZero() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.x = 0x00
        
        dex.execute(cpu: cpu)
        
        #expect(cpu.x == 0xFF)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testNegativeFromNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.x = 0xFF
        
        dex.execute(cpu: cpu)
        
        #expect(cpu.x == 0xFE)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
