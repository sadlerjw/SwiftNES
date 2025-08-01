//
//  ClosureAddressable.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//


class ClosureAddressable : Addressable {
    let length: Int
    let name: String
    
    let writeClosure: (Byte, Offset) -> Void
    let readClosure: (Offset) -> Byte
    
    init(length: Int,
         name: String,
         write: @escaping (Byte, Offset) -> Void,
         read: @escaping (Offset) -> Byte) {
        self.length = length
        self.name = name
        self.writeClosure = write
        self.readClosure = read
    }
    
    func write(_ value: Byte, at offset: Offset) {
        writeClosure(value, offset)
    }
    
    func read(at offset: Offset) -> Byte {
        return readClosure(offset)
    }
}
