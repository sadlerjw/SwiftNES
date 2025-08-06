//
//  ASL.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct JMP : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x4C,
                  totalBytes: 3,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
            .init(opcode: 0x6C,
                  totalBytes: 3,
                  defaultCycles: 5,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Indirect.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            guard let fetchedFromAddress = cpu.fetchedFromAddress else { fatalError() }
            
            cpu.pc = fetchedFromAddress
            
            return nil
        }
    }
}
