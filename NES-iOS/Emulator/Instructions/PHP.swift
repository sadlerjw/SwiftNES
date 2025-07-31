//
//  AND.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct PHP : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x08,
                  totalBytes: 1,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let b = cpu.status.contains(.b)
            cpu.status.insert(.b)
            
            cpu.stack.push(cpu.status.rawValue)
            
            cpu.status.setB(b)
            
            return nil
        }
    }
}
