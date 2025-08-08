//
//  Immediate.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    class Immediate : MemoryBasedAddressingMode {
        var computedAddress: AddressingModeComputedAddress?
        var fetchedData: Byte?
        
        required init() {}

        func computeAddress(cpu: borrowing CPU) {
            assert(computedAddress == nil)
            guard computedAddress == nil else { return }
            
            computedAddress = .init(cpu.pc, crossedPageBoundary: false)
            cpu.pc += 1
        }
        
        func write(_ value: Byte, cpu: borrowing CPU) {
            fatalError("Trying to write using immediate addressing mode")
        }
    }
}
