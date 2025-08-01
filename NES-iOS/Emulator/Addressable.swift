//
//  Addressable.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//


protocol Addressable : AnyObject {
    typealias Offset = Address
    
    var length : Int { get }
    var name : String { get }
    
    func write(_ value: Byte, at offset: Offset)
    func read(at offset: Offset) -> Byte
}

