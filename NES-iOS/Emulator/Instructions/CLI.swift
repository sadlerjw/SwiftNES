//
//  CLC.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct CLI : ModifyFlagInstruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x58,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        let set = false
        let flag = CPU.StatusRegister.i
    }
}
