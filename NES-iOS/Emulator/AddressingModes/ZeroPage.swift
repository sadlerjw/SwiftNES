//
//  ZeroPage.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    struct ZeroPage : MemoryBasedAddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let zeroPageAddress = Address(cpu.bus.read(cpu.pc))
            cpu.pc += 1
            
            cpu.fetchedFromAddress = zeroPageAddress
            cpu.fetchedData = cpu.bus.read(zeroPageAddress)
        }
    }
    
    struct ZeroPageX : MemoryBasedAddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            cpu.pc += 1
            let address = Address(zeroPageBaseAddress &+ cpu.x)

            cpu.fetchedFromAddress = address
            cpu.fetchedData = cpu.bus.read(address)
        }
    }
    
    struct ZeroPageY : MemoryBasedAddressingMode {
        static let sharedInstance = Self.init()

        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            cpu.pc += 1
            let address = Address(zeroPageBaseAddress &+ cpu.y)

            cpu.fetchedFromAddress = address
            cpu.fetchedData = cpu.bus.read(address)
        }
    }
}
