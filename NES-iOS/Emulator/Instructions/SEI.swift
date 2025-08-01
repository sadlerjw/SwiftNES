//
//  CLC.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct SEI : ModifyFlagInstruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x78,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        let set = true
        let flag = CPU.StatusRegister.i
        
        func postExecute(cpu: CPU) {
            cpu.changingInterruptsEnabledShouldBeDelayed = true
        }
    }
}
