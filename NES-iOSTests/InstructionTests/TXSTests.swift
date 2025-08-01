//
//  LDATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct TXSTests {
    let nes = NES()
    let txs = Instructions.TXS()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test(arguments: [0x1D, 0xF3, 0x00])
    func test(value: Byte){
        cpu.status = []
        cpu.x = value
        
        txs.execute(cpu: cpu)
        
        #expect(cpu.stack.stackPointer == value)
        #expect(cpu.status == [])
    }
}
