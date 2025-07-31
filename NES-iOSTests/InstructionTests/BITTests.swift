//
//  BITTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct BITTests {
    let nes = NES()
    let bit = Instructions.BIT()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.o)
        cpu.status.insert(.n)
        
        cpu.a =           0b0000_0001
        cpu.fetchedData = 0b1000_0000
        
        bit.execute(cpu: cpu)
        
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testOverflow() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.o)
        cpu.status.insert(.n)
        
        cpu.a =           0b0100_1001
        cpu.fetchedData = 0b1100_1000
        
        bit.execute(cpu: cpu)
        
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testNegative() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.o)
        cpu.status.insert(.n)
        
        cpu.a =           0b1000_1001
        cpu.fetchedData = 0b1100_1000
        
        bit.execute(cpu: cpu)
        
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.o))
        #expect(cpu.status.contains(.n))
    }

}
