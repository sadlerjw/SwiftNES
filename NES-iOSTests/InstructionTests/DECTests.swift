//
//  DEXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct DECTests {
    let nes = NES()
    let dec = Instructions.DEC()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0x1A
        
        let result = dec.execute(cpu: cpu)
        
        #expect(result == 0x19)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0x01
        
        let result = dec.execute(cpu: cpu)
        
        #expect(result == 0x00)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }

    @Test func testNegativeFromZero() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.fetchedData = 0x00
        
        let result = dec.execute(cpu: cpu)
        
        #expect(result == 0xFF)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testNegativeFromNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.fetchedData = 0xFF
        
        let result = dec.execute(cpu: cpu)
        
        #expect(result == 0xFE)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
