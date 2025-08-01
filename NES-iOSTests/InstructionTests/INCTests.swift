//
//  DEXTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct INCTests {
    let nes = NES(allRAM: true)
    let inc = Instructions.INC()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0x1A
        
        let result = inc.execute(cpu: cpu)
        
        #expect(result == 0x1B)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0xFF
        
        let result = inc.execute(cpu: cpu)
        
        #expect(result == 0x00)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }

    @Test func testNegativeFromPositive() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.fetchedData = 0x7F
        
        let result = inc.execute(cpu: cpu)
        
        #expect(result == 0x80)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testNegativeFromNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.fetchedData = 0xF8
        
        let result = inc.execute(cpu: cpu)
        
        #expect(result == 0xF9)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
