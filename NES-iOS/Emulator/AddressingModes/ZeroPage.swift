//
//  ZeroPage.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    struct ZeroPage : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let zeroPageAddress = cpu.bus.read(cpu.pc)
            cpu.fetchedData = cpu.bus.read(UInt16(zeroPageAddress))
        }
    }
    
    struct ZeroPageX : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            let zeroPageAddress = zeroPageBaseAddress &+ cpu.x
            cpu.fetchedData = cpu.bus.read(UInt16(zeroPageAddress))
        }
    }
    
    struct ZeroPageY : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            let zeroPageAddress = zeroPageBaseAddress &+ cpu.y
            cpu.fetchedData = cpu.bus.read(UInt16(zeroPageAddress))
        }
    }
}
