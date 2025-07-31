//
//  Accumulator.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    struct Accumulator : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            cpu.fetchedData = cpu.a
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            cpu.a = value
        }
    }
}
