//
//  ADCTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct ADCTests {
    let nes = NES()
    let adc = Instructions.ADC()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func plainAdd() async throws {
        cpu.status.remove(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.o)
        cpu.status.insert(.n)
        
        cpu.fetchedData = 0x0F
        cpu.a = 0x61
        adc.execute(cpu: cpu)
        
        #expect(cpu.a == 0x70)
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func plainAddWithCarry() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.o)
        cpu.status.insert(.n)
        
        cpu.fetchedData = 0x0F
        cpu.a = 0x61
        adc.execute(cpu: cpu)
        
        #expect(cpu.a == 0x71)
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func overflowToNegative() async throws {
        cpu.status.remove(.c)
        cpu.status.insert(.z)
        cpu.status.remove(.o)
        cpu.status.remove(.n)
        
        cpu.fetchedData = 0x1D
        cpu.a = 0x71
        adc.execute(cpu: cpu)
        
        #expect(cpu.a == 0x8E)
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.o))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func overflowToNegativeWithCarry() async throws {
        cpu.status.insert(.c)
        cpu.status.insert(.z)
        cpu.status.remove(.o)
        cpu.status.remove(.n)
        
        cpu.fetchedData = 0x1D
        cpu.a = 0x71
        adc.execute(cpu: cpu)
        
        #expect(cpu.a == 0x8F)
        #expect(!cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.o))
        #expect(cpu.status.contains(.n))
    }
    
    @Test func overflowToPositive() async throws {
        cpu.status.remove(.c)
        cpu.status.insert(.z)
        cpu.status.insert(.o)
        cpu.status.remove(.n)
        
        cpu.fetchedData = 0x8D
        cpu.a = 0xF1
        adc.execute(cpu: cpu)
        
        #expect(cpu.a == 0x7E)
        #expect(cpu.status.contains(.c))
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }
    
    @Test func overflowToZero() async throws {
        cpu.status.remove(.c)
        cpu.status.remove(.z)
        cpu.status.insert(.o)
        cpu.status.remove(.n)
        
        cpu.fetchedData = 0x1D
        cpu.a = 0xE3
        adc.execute(cpu: cpu)
        
        #expect(cpu.a == 0x00)
        #expect(cpu.status.contains(.c))
        #expect(cpu.status.contains(.z))
        #expect(!cpu.status.contains(.o))
        #expect(!cpu.status.contains(.n))
    }

}
