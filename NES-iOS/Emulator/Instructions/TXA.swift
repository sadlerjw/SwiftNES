//
//  LDA.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//


extension Instructions {
    struct TXA : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x8A,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let value = cpu.x
            cpu.a = value
            
            cpu.status.setZ(value == 0)
            cpu.status.setN(value & 0x80 != 0)
            
            return nil
        }
    }
}
