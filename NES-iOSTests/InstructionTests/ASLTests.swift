//
//  ASLTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct ASLTests {
    let nes = NES(allRAM: true)
    let asl = Instructions.ASL()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNormal() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.fetchedData = 0b00010011
        let expected =    0b00100110
        
        let result = asl.execute(cpu: cpu)
        
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
        cpu.fetchedData = 0b10000000
        let expected =    0b00000000
        
        let result = asl.execute(cpu: cpu)
        
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
        
        let result = asl.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(!cpu.status.contains(.c))
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testNegativeFromPositive() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.fetchedData = 0b01010011
        let expected =    0b10100110
        
        let result = asl.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func testNegativeFromNegative() async throws {
        cpu.status.remove(.c)
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.fetchedData = 0b11010011
        let expected =    0b10100110
        
        let result = asl.execute(cpu: cpu)
        
        if let result {
            #expect(result == expected)
        } else {
            #expect(Bool(false), "Should not return nil")
        }
        #expect(cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
