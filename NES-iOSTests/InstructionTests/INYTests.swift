//
//  DEXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct INYTests {
    let nes = NES(allRAM: true)
    let iny = Instructions.INY()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.y = 0x1A
        
        iny.execute(cpu: cpu)
        
        #expect(cpu.y == 0x1B)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.y = 0xFF
        
        iny.execute(cpu: cpu)
        
        #expect(cpu.y == 0x00)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }

    @Test func testNegativeFromPositive() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.y = 0x7F
        
        iny.execute(cpu: cpu)
        
        #expect(cpu.y == 0x80)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testNegativeFromNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.y = 0xF8
        
        iny.execute(cpu: cpu)
        
        #expect(cpu.y == 0xF9)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
