//
//  Implied.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    struct Implied : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU) {
            // No-op!
        }
    }
}
