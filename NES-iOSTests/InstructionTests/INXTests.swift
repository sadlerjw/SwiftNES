//
//  DEXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct INXTests {
    let nes = NES()
    let inx = Instructions.INX()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.x = 0x1A
        
        inx.execute(cpu: cpu)
        
        #expect(cpu.x == 0x1B)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.x = 0xFF
        
        inx.execute(cpu: cpu)
        
        #expect(cpu.x == 0x00)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }

    @Test func testNegativeFromPositive() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.x = 0x7F
        
        inx.execute(cpu: cpu)
        
        #expect(cpu.x == 0x80)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testNegativeFromNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.x = 0xF8
        
        inx.execute(cpu: cpu)
        
        #expect(cpu.x == 0xF9)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
