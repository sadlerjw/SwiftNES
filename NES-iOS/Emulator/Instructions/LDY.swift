//
//  LDX.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct LDY : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xA0,
                  totalBytes: 2,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.self),
            .init(opcode: 0xA4,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.self),
            .init(opcode: 0xB4,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.self),
            .init(opcode: 0xAC,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.self),
            .init(opcode: 0xBC,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.self),
        ]
        
        @discardableResult
        func execute(addressingMode: any AddressingMode,
                     readAddsCycleIfPagedCrossed: Bool,
                     cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let fetchedData = addressingMode.fetch(cpu: cpu, addingCycleIfPageCrossed: readAddsCycleIfPagedCrossed)
            
            cpu.y = fetchedData
            
            cpu.status.setZ(fetchedData == 0)
            cpu.status.setN(fetchedData >> 7 == 1)
            
            return nil
        }
    }
}
