//
//  BCS.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct BCS : BranchInstruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xB0,
                  totalBytes: 2,
                  defaultCycles: 2,
                  addsCycleIfPageCrossed: false, // technically true - but since it's a relative signed 8-bit integer, we'll deal with it manually in `execute`
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.self),
        ]
        
        func willBranch(cpu: CPU) -> Bool {
            return cpu.status.contains(.c)
        }
    }
}
