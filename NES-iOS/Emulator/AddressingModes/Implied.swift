//
//  Implied.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    struct Implied : AddressingMode {
        static let sharedInstance = Self.init()
        
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            // No-op!
            cpu.fetchedFromAddress = nil
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            fatalError("Trying to write using implied addressing mode")
        }
    }
}
