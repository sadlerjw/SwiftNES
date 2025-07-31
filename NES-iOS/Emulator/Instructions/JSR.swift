//
//  ASL.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct JSR : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x20,
                  totalBytes: 3,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            guard let fetchedFromAddress = cpu.fetchedFromAddress else { fatalError() }
            
            let low = cpu.fetchedData
            let high = cpu.bus.read(fetchedFromAddress &+ 1)
            cpu.pc += 1
            
            cpu.stack.push(cpu.pc)
            
            let newPC = Address(low: low, high: high)
            cpu.pc = newPC
            
            return nil
        }
    }
}
