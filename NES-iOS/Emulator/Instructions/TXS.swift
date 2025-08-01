//
//  LDA.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//


extension Instructions {
    struct TXS : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x9A,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let value = cpu.x
            cpu.stack.stackPointer = value

            return nil
        }
    }
}
