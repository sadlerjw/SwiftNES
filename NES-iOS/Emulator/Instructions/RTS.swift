//
//  CLC.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct RTS : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x60,
                  totalBytes: 1,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let newPC = cpu.stack.popAddress() + 1
            cpu.pc = newPC

            return nil
        }
    }
}
