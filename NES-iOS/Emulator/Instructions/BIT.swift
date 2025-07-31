//
//  BIT.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct BIT : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x24,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0x2C,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),

        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let and = cpu.a & cpu.fetchedData
            
            cpu.status.setZ(and == 0)
            cpu.status.setO(and & 0x40 != 0)
            cpu.status.setN(and & 0x80 != 0)
            
            return nil
        }
    }
}
