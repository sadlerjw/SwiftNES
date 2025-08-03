//
//  OAMTable.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//


struct OAMTable {
    var raw = RAM<256>()
    
    subscript(index: Address) -> OAMEntry {
        get {
            precondition(index >= 0)
            precondition(index < 64)
            let baseIndex = index * 4
            
            let internalAttributes = internal_oam_attributes(reg: raw.read(at: baseIndex + 2))
            let internalEntry = internal_oam_entry(y: raw.read(at: baseIndex),
                                                   tile_index: raw.read(at: baseIndex + 1),
                                              attributes: internalAttributes,
                                                   x: raw.read(at: baseIndex + 3))
            
            return .init(rawValue: internalEntry)
        }
        set {
            precondition(index >= 0)
            precondition(index < 64)
            let baseIndex = index * 4
            
            raw.write(newValue.y, at: baseIndex)
            raw.write(newValue.tileIndex, at: baseIndex + 1)
            raw.write(newValue.attributes.rawValue.reg, at: baseIndex + 2)
            raw.write(newValue.x, at: baseIndex + 3)
        }
    }
}
