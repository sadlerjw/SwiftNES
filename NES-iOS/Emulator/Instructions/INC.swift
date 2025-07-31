//
//  DEX.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct INC : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xE6,
                  totalBytes: 2,
                  defaultCycles: 5,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0xF6,
                  totalBytes: 2,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.sharedInstance),
            .init(opcode: 0xEE,
                  totalBytes: 3,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
            .init(opcode: 0xFE,
                  totalBytes: 3,
                  defaultCycles: 7,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.sharedInstance),
        ]
        
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let result = cpu.fetchedData &+ 1
            cpu.status.setZ(result == 0)
            cpu.status.setN(result >> 7 == 1)
            
            return result
        }
    }
}
