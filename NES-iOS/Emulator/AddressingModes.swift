//
//  AddressingModes.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

protocol AddressingMode {
    static var sharedInstance : Self { get }
    var name : String { get }
    
    func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool)
    func write(_ value: Byte, cpu: borrowing CPU)
}

extension AddressingMode {
    func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
        // TODO: this is only here to resolve compilation errors for as-yet unimplemented modes.
        // Remove this later.
    }
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
    
    func isOnDifferentPage(from otherAddress: Address) -> Bool {
        return self & 0xFF00 != otherAddress & 0xFF00
    }
}
