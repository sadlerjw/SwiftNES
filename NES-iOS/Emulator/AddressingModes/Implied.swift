//
//  Implied.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    class Implied : AddressingMode {
        required init() {}
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) -> Byte {
            // No-op!
            return 0
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            fatalError("Trying to write using implied addressing mode")
        }
    }
}
