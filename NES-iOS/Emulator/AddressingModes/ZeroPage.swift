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
            let zeroPageAddress = Address(cpu.bus.read(cpu.pc))
            cpu.fetchedFromAddress = zeroPageAddress
            cpu.fetchedData = cpu.bus.read(zeroPageAddress)
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            let zeroPageAddress = cpu.bus.read(cpu.pc)
            cpu.bus.write(value, at: Address(zeroPageAddress))
        }
    }
    
    struct ZeroPageX : AddressingMode {
        static let sharedInstance = Self.init()
        
        private func address(cpu: CPU) -> Address {
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            return Address(zeroPageBaseAddress &+ cpu.x)
        }
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let address = address(cpu: cpu)
            cpu.fetchedFromAddress = address
            cpu.fetchedData = cpu.bus.read(address)
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            cpu.bus.write(value, at: address(cpu: cpu))
        }
    }
    
    struct ZeroPageY : AddressingMode {
        static let sharedInstance = Self.init()
        
        private func address(cpu: CPU) -> Address {
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            return Address(zeroPageBaseAddress &+ cpu.y)
        }
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let address = address(cpu: cpu)
            cpu.fetchedFromAddress = address
            cpu.fetchedData = cpu.bus.read(address)
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            cpu.bus.write(value, at: address(cpu: cpu))
        }
    }
}
