//
//  ASL.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct ASL : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x0A,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Accumulator.self),
            .init(opcode: 0x06,
                  totalBytes: 2,
                  defaultCycles: 5,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.self),
            .init(opcode: 0x16,
                  totalBytes: 2,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.self),
            .init(opcode: 0x0E,
                  totalBytes: 3,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.self),
            .init(opcode: 0x1E,
                  totalBytes: 3,
                  defaultCycles: 7,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.self),
            
        ]
        
        func execute(addressingMode: any AddressingMode,
                     readAddsCycleIfPagedCrossed: Bool,
                     cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let fetchedData = addressingMode.fetch(cpu: cpu, addingCycleIfPageCrossed: readAddsCycleIfPagedCrossed)
            
            let result = fetchedData << 1
            
            cpu.status.setC(fetchedData & 0x80 != 0)
            cpu.status.setZ(result == 0)
            cpu.status.setN(result & 0x80 != 0)
            
            return result
        }
    }
}
