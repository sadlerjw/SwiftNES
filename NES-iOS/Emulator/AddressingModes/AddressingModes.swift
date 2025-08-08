//
//  AddressingModes.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

struct AddressingModeComputedAddress {
    var address: Address
    var crossedPageBoundary: Bool
    
    init(_ address: Address, crossedPageBoundary: Bool) {
        self.address = address
        self.crossedPageBoundary = crossedPageBoundary
    }
}

protocol AddressingMode {
    var name : String { get }
    
    init()
    
    func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) -> Byte
    func write(_ value: Byte, cpu: borrowing CPU)
}

extension AddressingMode {
    var name : String {
        String(describing: type(of: self))
    }
}

enum AddressingModes {
    // Namespace for the various addressing modes
    // See the files in the AddressingModes folder
    // for implementations.
}

extension Address {
    init(low: Byte, high: Byte) {
        self = UInt16(high) << 8 | UInt16(low)
    }
    
    var low: Byte {
        return Byte(self & 0xFF)
    }
    
    var high: Byte {
        return Byte(self >> 8)
    }
    
    func isOnDifferentPage(from otherAddress: Address) -> Bool {
        return self & 0xFF00 != otherAddress & 0xFF00
    }
}
