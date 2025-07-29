//
//  NES.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

typealias Address = UInt16
typealias Byte = UInt8

class NES {
    let mainBus = MainBus()
    
    init () {
        mainBus.addDevice(RAM<0x0800>(), at: 0x0000)
    }
}
