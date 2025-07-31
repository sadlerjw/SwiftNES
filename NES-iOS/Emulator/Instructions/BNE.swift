//
//  BNE.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct BNE : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xD0,
                  totalBytes: 1,
                  defaultCycles: 2,
                  addsCycleIfPageCrossed: false, // technically true - but since it's a relative signed 8-bit integer, we'll deal with it manually in `execute`
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.sharedInstance),
        ]
        
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let willBranch = !cpu.status.contains(.z)
            
            if willBranch {
                cpu.cyclesBeforeNextInstruction += 1
                let offset = Int8(bitPattern: cpu.fetchedData)
                let newPC : UInt16 = UInt16(Int32(cpu.pc) + Int32(offset))
                
                let pageCrossed : Bool = (cpu.pc & 0xFF00) != (newPC & 0xFF00)
                
                if pageCrossed {
                    cpu.cyclesBeforeNextInstruction += 1
                }
                
                cpu.pc = newPC
            }
            
            return nil
        }
    }
}
