//
//  LDATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct TXATests {
    let nes = NES(allRAM: true)
    let txa = Instructions.TXA()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test(arguments: zip([0x1D, 0xF3, 0x00], [CPU.StatusRegister](arrayLiteral: [], [.n], [.z])))
    func test(value: Byte, expectedStatus: CPU.StatusRegister){
        cpu.status = []
        cpu.x = value
        
        txa.execute(cpu: cpu)
        
        #expect(cpu.a == value)
        #expect(cpu.status == expectedStatus)
    }
}
