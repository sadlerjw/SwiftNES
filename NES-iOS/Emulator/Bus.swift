//
//  Bus.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

protocol Bus {
    associatedtype Source
    
    mutating func write(_ value: Byte, at address: Address, from source: Source)
    func read(_ address: Address, from source: Source) -> UInt8
}

extension Bus where Source == Void {
    mutating func write(_ value: Byte, at address: Address) {
        self.write(value, at: address, from: ())
    }
    
    func read(_ address: Address) -> UInt8 {
        self.read(address, from: ())
    }
}

protocol BusDevice : AnyObject {
    typealias Offset = Address
    
    var length : Offset { get }
    var name : String { get }
    
    func write(_ value: Byte, at offset: Offset)
    func read(at offset: Offset) -> Byte
}
