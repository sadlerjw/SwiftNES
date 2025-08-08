//
//  BranchInstruction.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

protocol BranchInstruction: Instruction {
    func willBranch(cpu: CPU) -> Bool
}

extension BranchInstruction {
    @discardableResult
    func execute(addressingMode: any AddressingMode,
                 readAddsCycleIfPagedCrossed: Bool,
                 cpu: borrowing CPU) -> ReadModifyWriteResult? {
        let fetchedData = addressingMode.fetch(cpu: cpu, addingCycleIfPageCrossed: readAddsCycleIfPagedCrossed)
        
        if willBranch(cpu: cpu) {
            cpu.cyclesBeforeNextInstruction += 1
            let offset = Int8(bitPattern: fetchedData)
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
