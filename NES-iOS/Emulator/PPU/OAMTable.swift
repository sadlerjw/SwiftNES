//
//  OAMTable.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//


struct OAMTable {
    var raw = InlineArray<256, Byte>(repeating: 0)
    
    subscript(index: Int) -> OAMEntry {
        get {
            precondition(index >= 0)
            precondition(index < 64)
            let baseIndex = index * 4
            
            let internalAttributes = internal_oam_attributes(reg: raw[baseIndex + 2])
            let internalEntry = internal_oam_entry(y: raw[baseIndex],
                                              tile_index: raw[baseIndex + 1],
                                              attributes: internalAttributes,
                                              x: raw[baseIndex + 3])
            
            return .init(rawValue: internalEntry)
        }
        set {
            precondition(index >= 0)
            precondition(index < 64)
            let baseIndex = index * 4
            
            raw[baseIndex] = newValue.y
            raw[baseIndex + 1] = newValue.tileIndex
            raw[baseIndex + 2] = newValue.attributes.rawValue.reg
            raw[baseIndex + 3] = newValue.x
        }
    }
}