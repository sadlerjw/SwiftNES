//
//  LDA.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//


extension Instructions {
    struct STX : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x86,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0x96,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageY.sharedInstance),
            .init(opcode: 0x8E,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            guard let address = cpu.fetchedFromAddress else { fatalError("Must have address to write to") }
            cpu.bus.write(cpu.x, at: address)
            
            return nil
        }
    }
}
