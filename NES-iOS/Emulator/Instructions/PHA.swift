//
//  AND.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct PHA : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x48,
                  totalBytes: 1,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            cpu.stack.push(cpu.a)
            
            return nil
        }
    }
}
