//
//  ModifyFlagInstruction.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-31.
//

protocol ModifyFlagInstruction: Instruction {
    var set : Bool { get }
    var flag : CPU.StatusRegister { get }
    
    func postExecute(cpu: CPU)
}

extension ModifyFlagInstruction {
    @discardableResult
    func execute(addressingMode: any AddressingMode,
                 readAddsCycleIfPagedCrossed: Bool,
                 cpu: borrowing CPU) -> ReadModifyWriteResult? {
        if `set` {
            cpu.status.insert(flag)
        } else {
            cpu.status.remove(flag)
        }
        
        postExecute(cpu: cpu)
        
        return nil
    }
    
    func postExecute(cpu: CPU) {}
}
