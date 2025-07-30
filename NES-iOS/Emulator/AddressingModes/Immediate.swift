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
            cpu.fetchedData = cpu.bus.read(cpu.pc)
            cpu.pc += 1
        }
    }
}
