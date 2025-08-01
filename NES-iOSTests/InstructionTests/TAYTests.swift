//
//  LDATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct TAYTests {
    let nes = NES(allRAM: true)
    let tay = Instructions.TAY()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test(arguments: zip([0x1D, 0xF3, 0x00], [CPU.StatusRegister](arrayLiteral: [], [.n], [.z])))
    func test(value: Byte, expectedStatus: CPU.StatusRegister){
        cpu.status = []
        cpu.a = value
        
        tay.execute(cpu: cpu)
        
        #expect(cpu.y == value)
        #expect(cpu.status == expectedStatus)
    }
}
