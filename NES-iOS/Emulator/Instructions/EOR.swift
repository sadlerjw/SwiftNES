//
//  AND.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct EOR : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x49,
                  totalBytes: 2,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.sharedInstance),
            .init(opcode: 0x45,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0x55,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.sharedInstance),
            .init(opcode: 0x4D,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: false,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
            .init(opcode: 0x5D,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.sharedInstance),
            .init(opcode: 0x59,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteY.sharedInstance),
            .init(opcode: 0x41,
                  totalBytes: 2,
                  defaultCycles: 6,
                  addsCycleIfPageCrossed: false,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectX.sharedInstance),
            .init(opcode: 0x51,
                  totalBytes: 2,
                  defaultCycles: 5,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectY.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            cpu.a = cpu.a ^ cpu.fetchedData
            
            cpu.status.setZ(cpu.a == 0)
            cpu.status.setN(cpu.a & 0x80 != 0)
            
            return 0
        }
    }
}
