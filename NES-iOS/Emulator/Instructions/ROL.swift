//
//  ASL.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct ROL : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x2A,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Accumulator.sharedInstance),
            .init(opcode: 0x26,
                  totalBytes: 2,
                  defaultCycles: 5,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0x36,
                  totalBytes: 2,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.sharedInstance),
            .init(opcode: 0x2E,
                  totalBytes: 3,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
            .init(opcode: 0x3E,
                  totalBytes: 3,
                  defaultCycles: 7,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.sharedInstance),
            
        ]
        
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let result = cpu.fetchedData << 1 | ((cpu.fetchedData & 0x80) >> 7)
            
            cpu.status.setC(cpu.fetchedData & 0x80 != 0)
            cpu.status.setZ(result == 0)
            cpu.status.setN(result & 0x80 != 0)
            
            return result
        }
    }
}
