//
//  LDA.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//


extension Instructions {
    struct STY : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x84,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.self),
            .init(opcode: 0x94,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.self),
            .init(opcode: 0x8C,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.self),
        ]
        
        @discardableResult
        func execute(addressingMode: any AddressingMode,
                     readAddsCycleIfPagedCrossed: Bool,
                     cpu: borrowing CPU) -> ReadModifyWriteResult? {
            addressingMode.write(cpu.y, cpu: cpu)

            return nil
        }
    }
}
