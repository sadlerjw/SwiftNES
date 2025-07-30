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
    struct Implied : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU) {
            // No-op!
        }
    }
    
    struct Immediate : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            cpu.fetchedData = cpu.bus.read(cpu.pc)
            cpu.pc += 1
        }
    }
    
    struct ZeroPage : AddressingMode {
        static let sharedInstance = Self.init()
    }
    
    struct ZeroPageX : AddressingMode {
        static let sharedInstance = Self.init()
    }
    
    struct ZeroPageY : AddressingMode {
        static let sharedInstance = Self.init()
    }
    
    struct Absolute : AddressingMode {
        static let sharedInstance = Self.init()
    }
    
    struct AbsoluteX : AddressingMode {
        static let sharedInstance = Self.init()
    }
    
    struct AbsoluteY : AddressingMode {
        static let sharedInstance = Self.init()
    }
    
    struct IndirectX : AddressingMode {
        static let sharedInstance = Self.init()
    }
    
    struct IndirectY : AddressingMode {
        static let sharedInstance = Self.init()
    }
}
