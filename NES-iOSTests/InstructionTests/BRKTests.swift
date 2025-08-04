//
//  BRKTests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-31.
//

import Testing
@testable import NES_iOS

@MainActor struct BRKTests {
    let nes = NES(allRAM: true)
    let brk = Instructions.BRK()
    var cpu: CPU {
        return nes.cpu
    }

    @Test func test() async throws {
        nes.startup()
        cpu.status = [.c, .n, .o]
        cpu.pc = 0xABCD
        cpu.pc += 1
        
        // Set the address of the interrupt handler
        cpu.bus.write(0x34, at: NES.MainBusAddresses.brkVector)
        cpu.bus.write(0x12, at: NES.MainBusAddresses.brkVector + 1)
        
        brk.execute(cpu: cpu)
        
        #expect(cpu.status == [.c, .n, .o, .i])
        #expect(cpu.pc == 0x1234)
        #expect(cpu.stack.popByte() == CPU.StatusRegister(arrayLiteral: [.c, .n, .o, .b]).rawValue)
        #expect(cpu.stack.popAddress() == 0xABCD + 2)
    }

}
