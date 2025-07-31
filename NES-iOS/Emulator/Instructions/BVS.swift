//
//  BNE.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct BVS : BranchInstruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x70,
                  totalBytes: 2,
                  defaultCycles: 2,
                  addsCycleIfPageCrossed: false, // technically true - but since it's a relative signed 8-bit integer, we'll deal with it manually in `execute`
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.sharedInstance),
        ]
        
        func willBranch(cpu: CPU) -> Bool {
            return cpu.status.contains(.o)
        }
    }
}
