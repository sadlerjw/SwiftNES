//
//  AND.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct AND : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x29,
                  totalBytes: 2,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.self),
            .init(opcode: 0x25,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.self),
            .init(opcode: 0x35,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.self),
            .init(opcode: 0x2D,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: false,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.self),
            .init(opcode: 0x3D,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.self),
            .init(opcode: 0x39,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteY.self),
            .init(opcode: 0x21,
                  totalBytes: 2,
                  defaultCycles: 6,
                  addsCycleIfPageCrossed: false,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectX.self),
            .init(opcode: 0x31,
                  totalBytes: 2,
                  defaultCycles: 5,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectY.self),
        ]
        
        @discardableResult
        func execute(addressingMode: any AddressingMode,
                     readAddsCycleIfPagedCrossed: Bool,
                     cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let fetchedData = addressingMode.fetch(cpu: cpu, addingCycleIfPageCrossed: readAddsCycleIfPagedCrossed)
            
            cpu.a = cpu.a & fetchedData
            
            cpu.status.setZ(cpu.a == 0)
            cpu.status.setN(cpu.a & 0x80 != 0)
            
            return nil
        }
    }
}
