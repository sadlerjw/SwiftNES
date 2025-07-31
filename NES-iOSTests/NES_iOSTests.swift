//
//  NES_iOSTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-29.
//

import Testing
@testable import NES_iOS

@MainActor struct CpuRegisterTests {

    @Test func CPURegistersAtStartup() {
        let nes = NES()
        nes.mainBus.write(0xDE, at: 0xFFFC)
        nes.mainBus.write(0x12, at: 0xFFFD)
        nes.startup()
        
        #expect(nes.cpu.a == 0)
        #expect(nes.cpu.x == 0)
        #expect(nes.cpu.y == 0)
        #expect(nes.cpu.pc == 0x12DE)
        #expect(nes.cpu.stack.stackPointer == 0xFD)
        #expect(nes.cpu.status == .i)
    }
    
    @Test func CPURegistersAtReset() {
        let nes = NES()
        nes.startup()
        
        #expect(nes.cpu.pc == 0x0000)
        
        nes.mainBus.write(0xDE, at: 0xFFFC)
        nes.mainBus.write(0x12, at: 0xFFFD)
        
        nes.cpu.a = 0xDE
        nes.cpu.x = 0x12
        nes.cpu.y = 0x34
        nes.cpu.pc = 0x1234
        nes.cpu.stack.stackPointer = 0xAB
        nes.cpu.status = [.c, .d, .n]
        
        nes.cpu.reset()
        
        #expect(nes.cpu.a == 0xDE)
        #expect(nes.cpu.x == 0x12)
        #expect(nes.cpu.y == 0x34)
        #expect(nes.cpu.pc == 0x12DE)
        #expect(nes.cpu.stack.stackPointer == 0xA8)
        #expect(nes.cpu.status == [.c, .d, .n, .i])
    }

}
