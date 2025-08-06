//
//  Addressable.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//


protocol Addressable : AnyObject, Sequence where Iterator == AddressableIterator {
    typealias Offset = Address
    
    var length : Int { get }
    var name : String { get }
    
    func write(_ value: Byte, at offset: Offset)
    func read(at offset: Offset) -> Byte
}

extension Addressable {
    func makeIterator() -> Iterator {
        return AddressableIterator(addressable: self)
    }
}

struct AddressableIterator : IteratorProtocol {
    typealias Element = Byte
    
    unowned let addressable : any Addressable
    var index: Address = 0
    
    mutating func next() -> Element? {
        if index < addressable.length {
            return addressable.read(at: index)
        }
        return nil
    }
}

class DummyAddressable : Addressable {
    let length: Int
    var name: String {
        return "Dummy (length: \(length))"
    }
    
    init(length: Int) {
        self.length = length
    }
    
    func write(_ value: Byte, at offset: Offset) {
        // No-op
    }
    
    func read(at offset: Offset) -> Byte {
        return 0
    }
}
