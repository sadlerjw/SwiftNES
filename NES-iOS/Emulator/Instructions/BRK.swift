//
//  CLC.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct BRK : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x00,
                  totalBytes: 2,
                  defaultCycles: 7,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.self),
        ]
        
        @discardableResult
        func execute(addressingMode: any AddressingMode,
                     readAddsCycleIfPagedCrossed: Bool,
                     cpu: borrowing CPU) -> ReadModifyWriteResult? {
            cpu.status.insert(.b)
            cpu.pc += 1
            cpu.stack.push(cpu.pc)
            cpu.stack.push(cpu.status.rawValue)
            
            cpu.status.remove(.b)
            cpu.status.insert(.i)
            
            let pcLow = cpu.bus.read(NES.MainBusAddresses.brkVector)
            let pcHigh = cpu.bus.read(NES.MainBusAddresses.brkVector + 1)
            cpu.pc = Address(low: pcLow, high: pcHigh)

            return nil
        }
    }
}
