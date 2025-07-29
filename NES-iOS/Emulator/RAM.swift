//
//  RAM.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

class RAM<let staticLength: Int> : BusDevice {
    var length: Offset { return Offset(staticLength) }
    var name: String { return "RAM(\(staticLength))"}
    
    func write(_ value: Byte, at offset: Offset) {
        buffer[Int(offset)] = value
    }
    
    func read(at offset: Offset) -> UInt8 {
        return buffer[Int(offset)]
    }
    
    private var buffer = InlineArray<staticLength, Byte>(repeating: 0)
}
