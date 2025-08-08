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
                  addressingMode: AddressingModes.Implied.self),
        ]
        
        @discardableResult
        func execute(addressingMode: any AddressingMode,
                     readAddsCycleIfPagedCrossed: Bool,
                     cpu: borrowing CPU) -> ReadModifyWriteResult? {
            cpu.stack.push(cpu.a)
            
            return nil
        }
    }
}
