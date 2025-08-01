//
//  ASLTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct LSRTests {
    let nes = NES(allRAM: true)
    let lsr = Instructions.LSR()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNormal() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0b10010010
        let expected =    0b01001001
        
        let result = lsr.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZeroFromNonZero() async throws {
        cpu.status.remove(.c)
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0b00000001
        let expected =    0b00000000
        
        let result = lsr.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(cpu.status.contains(.c))
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZeroFromZero() async throws {
        cpu.status.insert(.c)
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0b00000000
        let expected =    0b00000000
        
        let result = lsr.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(!cpu.status.contains(.c))
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
}
