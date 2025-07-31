//
//  Absolute.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    struct Absolute : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let address = readAbsoluteBaseAddress(cpu: cpu)
            cpu.fetchedData = cpu.bus.read(address)
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            let address = readAbsoluteBaseAddress(cpu: cpu)
            cpu.bus.write(value, at: address)
        }
    }
    
    struct AbsoluteX : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let baseAddress = readAbsoluteBaseAddress(cpu: cpu)
            let address = baseAddress &+ UInt16(cpu.x)
            cpu.fetchedData = cpu.bus.read(address)
            
            if addingCycleIfPageCrossed && address.isOnDifferentPage(from: baseAddress) {
                cpu.cyclesBeforeNextInstruction += 1
            }
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            let baseAddress = readAbsoluteBaseAddress(cpu: cpu)
            let address = baseAddress &+ UInt16(cpu.x)
            cpu.bus.write(value, at: address)
        }
    }
    
    struct AbsoluteY : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let baseAddress = readAbsoluteBaseAddress(cpu: cpu)
            let address = baseAddress &+ UInt16(cpu.y)
            cpu.fetchedData = cpu.bus.read(address)
            
            if addingCycleIfPageCrossed && address.isOnDifferentPage(from: baseAddress) {
                cpu.cyclesBeforeNextInstruction += 1
            }
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            let baseAddress = readAbsoluteBaseAddress(cpu: cpu)
            let address = baseAddress &+ UInt16(cpu.y)
            cpu.bus.write(value, at: address)
        }
    }
}

fileprivate func readAbsoluteBaseAddress(cpu: borrowing CPU) -> Address {
    let lowWord = cpu.bus.read(cpu.pc)
    cpu.pc += 1
    
    let highWord = cpu.bus.read(cpu.pc)

    return Address(low: lowWord, high: highWord)
}
