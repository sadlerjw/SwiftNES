//
//  BIT.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct BIT : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x24,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.self),
            .init(opcode: 0x2C,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.self),

        ]
        
        @discardableResult
        func execute(addressingMode: any AddressingMode,
                     readAddsCycleIfPagedCrossed: Bool,
                     cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let fetchedData = addressingMode.fetch(cpu: cpu, addingCycleIfPageCrossed: readAddsCycleIfPagedCrossed)
            
            let and = cpu.a & fetchedData
            
            cpu.status.setZ(and == 0)
            cpu.status.setO(fetchedData & (1 << 6) != 0)
            cpu.status.setN(fetchedData & (1 << 7) != 0)
            
            return nil
        }
    }
}
