//
//  LDATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct LDATests {
    let nes = NES(allRAM: true)
    let lda = Instructions.LDA()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func testNormal() async throws {
        cpu.status.insert(.z)
        cpu.status.insert(.n)
        cpu.a = 0x12
        cpu.fetchedData = 0x5D
        
        lda.execute(cpu: cpu)
        
        #expect(cpu.a == 0x5D)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testZero() async throws {
        cpu.status.remove(.z)
        cpu.status.insert(.n)
        cpu.a = 0x12
        cpu.fetchedData = 0x00
        
        lda.execute(cpu: cpu)
        
        #expect(cpu.a == 0x00)
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func testNegative() async throws {
        cpu.status.insert(.z)
        cpu.status.remove(.n)
        cpu.a = 0x12
        cpu.fetchedData = 0x9C
        
        lda.execute(cpu: cpu)
        
        #expect(cpu.a == 0x9C)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
    }
}
