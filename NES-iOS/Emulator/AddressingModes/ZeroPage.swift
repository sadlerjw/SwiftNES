//
//  ZeroPage.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    class ZeroPage : MemoryBasedAddressingMode {
        var computedAddress: AddressingModeComputedAddress?
        var fetchedData: Byte?
        
        required init() {}

        func computeAddress(cpu: borrowing CPU) {
            assert(computedAddress == nil)
            guard computedAddress == nil else { return }
            
            let zeroPageAddress = Address(cpu.bus.read(cpu.pc))
            cpu.pc += 1
            
            computedAddress = .init(zeroPageAddress, crossedPageBoundary: false)
        }
    }
    
    class ZeroPageX : MemoryBasedAddressingMode {
        var computedAddress: AddressingModeComputedAddress?
        var fetchedData: Byte?
        
        required init() {}
        
        func computeAddress(cpu: borrowing CPU) {
            assert(computedAddress == nil)
            guard computedAddress == nil else { return }
            
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            cpu.pc += 1
            let address = Address(zeroPageBaseAddress &+ cpu.x)
            
            computedAddress = .init(address, crossedPageBoundary: false)
        }
    }
    
    class ZeroPageY : MemoryBasedAddressingMode {
        var computedAddress: AddressingModeComputedAddress?
        var fetchedData: Byte?
        
        required init() {}
        
        func computeAddress(cpu: borrowing CPU) {
            assert(computedAddress == nil)
            guard computedAddress == nil else { return }
            
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            cpu.pc += 1
            let address = Address(zeroPageBaseAddress &+ cpu.y)
            
            computedAddress = .init(address, crossedPageBoundary: false)
        }
    }
}
