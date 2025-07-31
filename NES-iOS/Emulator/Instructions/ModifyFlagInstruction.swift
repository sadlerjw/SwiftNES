//
//  ModifyFlagInstruction.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-31.
//

protocol ModifyFlagInstruction: Instruction {
    var set : Bool { get }
    var flag : CPU.StatusRegister { get }
}

extension ModifyFlagInstruction {
    @discardableResult
    func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
        if `set` {
            cpu.status.insert(flag)
        } else {
            cpu.status.remove(flag)
        }
        
        return nil
    }
}
