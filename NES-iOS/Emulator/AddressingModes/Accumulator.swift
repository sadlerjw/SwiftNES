//
//  Accumulator.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    class Accumulator : AddressingMode {
        required init() {}
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) -> Byte {
            return cpu.a
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            cpu.a = value
        }
    }
}
