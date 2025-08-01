//
//  ANDTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct ANDTests {
    let nes = NES(allRAM: true)
    let and = Instructions.AND()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.a =           0b00101111
        cpu.fetchedData = 0b00010011
        let expected =    0b00000011
        
        and.execute(cpu: cpu)
        
        #expect(cpu.a == expected)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.a =           0b00101111
        cpu.fetchedData = 0b00010000
        let expected =    0b00000000
        
        and.execute(cpu: cpu)
        
        #expect(cpu.a == expected)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.a =           0b10101111
        cpu.fetchedData = 0b10010011
        let expected =    0b10000011
        
        and.execute(cpu: cpu)
        
        #expect(cpu.a == expected)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
