//
//  ANDTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct PLATests {
    let nes = NES(allRAM: true)
    let pla = Instructions.PLA()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNegative() async throws {
        nes.startup()
        cpu.status.remove(.n)
        cpu.status.insert(.z)
        cpu.stack.push(Byte(0xF3))
        
        let stackPointer = cpu.stack.stackPointer
        
        pla.execute(cpu: cpu)
        
        #expect(cpu.a == 0xF3)
        #expect(!cpu.status.contains(.z))
        #expect(cpu.status.contains(.n))
        #expect(stackPointer != cpu.stack.stackPointer)
    }
    
    @Test func testPositive() async throws {
        nes.startup()
        cpu.status.insert(.n)
        cpu.status.insert(.z)
        cpu.stack.push(Byte(0x73))
        
        let stackPointer = cpu.stack.stackPointer
        
        pla.execute(cpu: cpu)
        
        #expect(cpu.a == 0x73)
        #expect(!cpu.status.contains(.z))
        #expect(!cpu.status.contains(.n))
        #expect(stackPointer != cpu.stack.stackPointer)
    }
}
