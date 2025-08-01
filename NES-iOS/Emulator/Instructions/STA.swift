//
//  LDA.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//


extension Instructions {
    struct STA : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x85,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0x95,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.sharedInstance),
            .init(opcode: 0x8D,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
            .init(opcode: 0x9D,
                  totalBytes: 3,
                  defaultCycles: 5,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.sharedInstance),
            .init(opcode: 0x99,
                  totalBytes: 3,
                  defaultCycles: 5,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteY.sharedInstance),
            .init(opcode: 0x81,
                  totalBytes: 2,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectX.sharedInstance),
            .init(opcode: 0x91,
                  totalBytes: 2,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectY.sharedInstance),
            
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            guard let address = cpu.fetchedFromAddress else { fatalError("Must have address to write to") }
            cpu.bus.write(cpu.a, at: address)
            
            return nil
        }
    }
}
