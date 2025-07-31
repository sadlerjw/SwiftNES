//
//  ANDTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct PHPTests {
    let nes = NES()
    let php = Instructions.PHP()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test func testNoB() async throws {
        nes.startup()
        cpu.status = [.c, .n, .z]
        
        php.execute(cpu: cpu)
        
        #expect(cpu.stack.popByte() == CPU.StatusRegister(arrayLiteral: [.c, .n, .z, .b]).rawValue)
        #expect(cpu.status == [.c, .n, .z, .one_unused]) // The one_unused bit is _always_ set
    }
    
    @Test func testB() async throws {
        nes.startup()
        cpu.status = [.n, .b]
        
        php.execute(cpu: cpu)
        
        #expect(cpu.stack.popByte() == CPU.StatusRegister(arrayLiteral: [.n, .b]).rawValue)
        #expect(cpu.status == [.n, .b, .one_unused]) // The one_unused bit is _always_ set
    }
}
