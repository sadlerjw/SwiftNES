//
//  CMP.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct CMP : CompareInstruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xC9,
                  totalBytes: 2,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.self),
            .init(opcode: 0xC5,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.self),
            .init(opcode: 0xD5,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.self),
            .init(opcode: 0xCD,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: false,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.self),
            .init(opcode: 0xDD,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.self),
            .init(opcode: 0xD9,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteY.self),
            .init(opcode: 0xC1,
                  totalBytes: 2,
                  defaultCycles: 6,
                  addsCycleIfPageCrossed: false,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectX.self),
            .init(opcode: 0xD1,
                  totalBytes: 2,
                  defaultCycles: 5,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectY.self),
        ]
        
        func firstComparisonValue(cpu: CPU) -> Byte {
            return cpu.a
        }
    }
}
