//
//  Immediate.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    struct Immediate : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            cpu.fetchedFromAddress = cpu.pc
            cpu.fetchedData = cpu.bus.read(cpu.pc)
            cpu.pc += 1
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            fatalError("Trying to write using immediate addressing mode")
        }
    }
}
