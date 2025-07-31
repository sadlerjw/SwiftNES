//
//  DEXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct DEYTests {
    let nes = NES()
    let dey = Instructions.DEY()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.y = 0x1A
        
        dey.execute(cpu: cpu)
        
        #expect(cpu.y == 0x19)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.y = 0x01
        
        dey.execute(cpu: cpu)
        
        #expect(cpu.y == 0x00)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }

    @Test func testNegativeFromZero() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.y = 0x00
        
        dey.execute(cpu: cpu)
        
        #expect(cpu.y == 0xFF)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testNegativeFromNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.y = 0xFF
        
        dey.execute(cpu: cpu)
        
        #expect(cpu.y == 0xFE)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
