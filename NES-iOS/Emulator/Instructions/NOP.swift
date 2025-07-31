//
//  NOP.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct NOP : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xEA,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            // no-op!
            return nil
        }
    }
}
