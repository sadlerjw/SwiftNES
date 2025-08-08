//
//  Absolute.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    class Absolute : MemoryBasedAddressingMode {
        var computedAddress: AddressingModeComputedAddress?
        var fetchedData: Byte?
        
        required init() {}

        func computeAddress(cpu: borrowing CPU) {
            assert(computedAddress == nil)
            guard computedAddress == nil else { return }
            
            computedAddress = .init(readAbsoluteBaseAddress(cpu: cpu), crossedPageBoundary: false)
        }
    }
    
    class AbsoluteX : MemoryBasedAddressingMode {
        var computedAddress: AddressingModeComputedAddress?
        var fetchedData: Byte?
        
        required init() {}

        func computeAddress(cpu: borrowing CPU) {
            assert(computedAddress == nil)
            guard computedAddress == nil else { return }
            
            let baseAddress = readAbsoluteBaseAddress(cpu: cpu)
            let address = baseAddress &+ UInt16(cpu.x)
            
            computedAddress = .init(address, crossedPageBoundary: address.isOnDifferentPage(from: baseAddress))
        }
    }
    
    class AbsoluteY : MemoryBasedAddressingMode {
        var computedAddress: AddressingModeComputedAddress?
        var fetchedData: Byte?
        
        required init() {}

        func computeAddress(cpu: borrowing CPU) {
            assert(computedAddress == nil)
            guard computedAddress == nil else { return }
            
            let baseAddress = readAbsoluteBaseAddress(cpu: cpu)
            let address = baseAddress &+ UInt16(cpu.y)
            
            computedAddress = .init(address, crossedPageBoundary: address.isOnDifferentPage(from: baseAddress))
        }
    }
}

fileprivate func readAbsoluteBaseAddress(cpu: borrowing CPU) -> Address {
    let lowWord = cpu.bus.read(cpu.pc)
    cpu.pc += 1
    
    let highWord = cpu.bus.read(cpu.pc)
    cpu.pc += 1

    return Address(low: lowWord, high: highWord)
}
