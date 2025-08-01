//
//  ADCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct SBCTests {
    let nes = NES(allRAM: true)
    let sbc = Instructions.SBC()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func plain() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.o)
        cpu.status.insert(.n)
        
        cpu.a = 113
        cpu.fetchedData = 0xFB // -5 (or 251, unsigned)
        sbc.execute(cpu: cpu)
        
        #expect(cpu.a == 118)
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func plainCarryUnset() async throws {
        cpu.status.remove(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.o)
        cpu.status.insert(.n)
        
        cpu.a = 113
        cpu.fetchedData = 0xFB // -5 (or 251, unsigned)
        sbc.execute(cpu: cpu)
        
        #expect(cpu.a == 117)
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func negativeCausingCarry() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.o)
        cpu.status.insert(.n)
        
        cpu.a = 0xFB // -5 (or 251, unsigned)
        cpu.fetchedData = 113
        
        sbc.execute(cpu: cpu)
        
        #expect(cpu.a == 0x8A) // -118 (or 138, unsigned)
        #expect(cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.o))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func overflowCausingCarry() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.o)
        cpu.status.insert(.n)
        
        cpu.a = 0xFB // -5 (or 251, unsigned) ....                    11111011
        cpu.fetchedData = 126 //              minus 01111110 --> plus 10000010
        //                                                          1(01111101) = 0x7D
        
        sbc.execute(cpu: cpu)
        
        #expect(cpu.a == 0x7D)
        #expect(cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }

}
