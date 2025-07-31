//
//  BITTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct CPYTests {
    let nes = NES()
    let cpy = Instructions.CPY()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testZero() async throws {
        cpu.status.remove(.c)
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        
        cpu.y = 89
        cpu.fetchedData = 89
        
        cpy.execute(cpu: cpu)
        
        #expect(cpu.status.contains(.c))
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testNonZeroCarry() async throws {
        cpu.status.remove(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        
        cpu.y = 89
        cpu.fetchedData = 43
        
        cpy.execute(cpu: cpu)
        
        #expect(cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testNegative() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        
        cpu.y = 89
        cpu.fetchedData = 121
        
        cpy.execute(cpu: cpu)
        
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testCarryNegative() async throws {
        cpu.status.remove(.c)
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        
        cpu.y = 223
        cpu.fetchedData = 39
        
        cpy.execute(cpu: cpu)
        
        #expect(cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
