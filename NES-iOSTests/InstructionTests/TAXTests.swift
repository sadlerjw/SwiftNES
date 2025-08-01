//
//  LDATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-07-30.
//

import Testing
@testable import NES_iOS

@MainActor struct TAXTests {
    let nes = NES(allRAM: true)
    let tax = Instructions.TAX()
    var cpu: CPU {
        return nes.cpu
    }
    
    @Test(arguments: zip([0x1D, 0xF3, 0x00], [CPU.StatusRegister](arrayLiteral: [], [.n], [.z])))
    func test(value: Byte, expectedStatus: CPU.StatusRegister){
        cpu.status = []
        cpu.a = value
        
        tax.execute(cpu: cpu)
        
        #expect(cpu.x == value)
        #expect(cpu.status == expectedStatus)
    }
}
