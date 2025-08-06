//
//  OAMTable.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//


struct OAMTable {
    var raw : any Addressable
    
    init() {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            raw = RAM_26<256>()
        } else {
            raw = RAM_legacy(length: 256)
        }
#else
        raw = RAM_legacy(length: 256)
#endif
    }
    
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
