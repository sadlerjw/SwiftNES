//
//  RAM.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

import Observation

@Observable
class RAM_legacy : Addressable {
    let length: Int
    var name: String { return "RAM(\(length))"}
    
    init(length: Int) {
        self.length = length
        self.buffer = .init(repeating: 0, count: length)
    }
    
    func write(_ value: Byte, at offset: Offset) {
        buffer[Int(offset)] = value
    }
    
    func read(at offset: Offset) -> UInt8 {
        return buffer[Int(offset)]
    }
    
    private var buffer : [Byte]
}

@available(iOS 19.0.0, *)
@Observable
class RAM_26<let staticLength: Int> : Addressable {
    var length: Int { return staticLength }
    var name: String { return "RAM(\(staticLength))"}
    
    func write(_ value: Byte, at offset: Offset) {
        buffer[Int(offset)] = value
    }
    
    func read(at offset: Offset) -> UInt8 {
        return buffer[Int(offset)]
    }
    
    private var buffer = InlineArray<staticLength, Byte>(repeating: 0)
}
