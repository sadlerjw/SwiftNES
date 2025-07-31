//
//  CompareInstruction.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-31.
//

protocol CompareInstruction : Instruction {
    func firstComparisonValue(cpu: CPU) -> Byte
}

extension CompareInstruction {
    @discardableResult
    func execute(cpu: borrowing CPU) -> ReadModifyWriteResult? {
        let value = firstComparisonValue(cpu: cpu)
        let result = value &- cpu.fetchedData
        
        cpu.status.setC(value >= cpu.fetchedData)
        cpu.status.setZ(value == cpu.fetchedData)
        cpu.status.setN(result & 0x80 != 0)
        
        return nil
    }
}
