//
//  Bus.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

protocol Bus : AnyObject {
    associatedtype Source
    
    func write(_ value: Byte, at address: Address, from source: Source)
    func read(_ address: Address, from source: Source) -> UInt8
}

extension Bus where Source == Void {
    func write(_ value: Byte, at address: Address) {
        self.write(value, at: address, from: ())
    }
    
    func read(_ address: Address) -> UInt8 {
        self.read(address, from: ())
    }
}


