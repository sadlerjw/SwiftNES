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
    func execute(addressingMode: any AddressingMode,
                 readAddsCycleIfPagedCrossed: Bool,
                 cpu: borrowing CPU) -> ReadModifyWriteResult? {
        let fetchedData = addressingMode.fetch(cpu: cpu, addingCycleIfPageCrossed: readAddsCycleIfPagedCrossed)
        
        let value = firstComparisonValue(cpu: cpu)
        let result = value &- fetchedData
        
        cpu.status.setC(value >= fetchedData)
        cpu.status.setZ(value == fetchedData)
        cpu.status.setN(result & 0x80 != 0)
        
        return nil
    }
}
