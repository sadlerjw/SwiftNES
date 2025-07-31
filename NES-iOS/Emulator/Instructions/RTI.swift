//
//  CLC.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension Instructions {
    struct RTI : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x40,
                  totalBytes: 1,
                  defaultCycles: 6,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        @discardableResult
        func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
            let poppedStatus = CPU.StatusRegister(rawValue: cpu.stack.popByte())
            
            cpu.status.setC(poppedStatus.contains(.c))
            cpu.status.setZ(poppedStatus.contains(.z))
            cpu.status.setI(poppedStatus.contains(.i))
            cpu.status.setD(poppedStatus.contains(.d))
            // Don't restore B
            // Don't restore one_unused (since it's always true)
            cpu.status.setO(poppedStatus.contains(.o))
            cpu.status.setN(poppedStatus.contains(.n))
            
            cpu.changingInterruptsEnabledShouldBeDelayed = false
            
            let newPC = cpu.stack.popAddress()
            cpu.pc = newPC

            return nil
        }
    }
}
