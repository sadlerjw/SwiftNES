//
//  ASLTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct ROLTests {
    let nes = NES()
    let rol = Instructions.ROL()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNormal() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0b00010010
        let expected =    0b00100100
        
        let result = rol.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testCarryNegative() async throws {
        cpu.status.remove(.c)
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.fetchedData = 0b11011011
        let expected =    0b10110111
        
        let result = rol.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.c)
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0b00000000
        let expected =    0b00000000
        
        let result = rol.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(!cpu.status.contains(.c))
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testNegative() async throws {
        cpu.status.insert(.c)
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0b01011011
        let expected =    0b10110110
        
        let result = rol.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
