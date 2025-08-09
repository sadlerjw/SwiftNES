//
//  VRAM.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-09.
//

class VRAM : Addressable {
    enum Table {
        case a
        case b
    }
    
    let length = 0x1000
    var name: String { "VRAM (mirroring: \(mirroring))" }
    
    var tableA : any Addressable = {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return RAM_26<0x400>()
        } else {
            return RAM_legacy(length: 0x400)
        }
#else
        return RAM_legacy(length: 0x400)
#endif
    }()
    
    var tableB : any Addressable = {
#if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            return RAM_26<0x400>()
        } else {
            return RAM_legacy(length: 0x400)
        }
#else
        return RAM_legacy(length: 0x400)
#endif
    }()

    
    var mirroring: INESFile.Mirroring = .horizontal
    
    private func tableAndOffsetFor(_ offset: Offset) -> (table: Table, offset: Offset) {
        assert(offset < 0x1000)
        
        if offset < 0x0400 {
            return (.a, offset)
        }
        
        switch mirroring {
        case .vertical:
            if offset < 0x0800 {
                return (.b, offset - 0x0400)
            }
            if offset < 0x0C00 {
                return (.a, offset - 0x0800)
            }
            return (.b, offset - 0x0C00)
        case .horizontal:
            if offset < 0x0800 {
                return (.a, offset - 0x0400)
            }
            if offset < 0x0C00 {
                return (.b, offset - 0x0800)
            }
            return (.b, offset - 0x0C00)
        }
    }
    
    func write(_ value: Byte, at offset: Offset) {
        let tableAndOffset = tableAndOffsetFor(offset)
        switch tableAndOffset.0 {
        case .a:
            tableA.write(value, at: tableAndOffset.1)
        case .b:
            tableB.write(value, at: tableAndOffset.1)
        }
    }
    
    func read(at offset: Offset) -> Byte {
        let tableAndOffset = tableAndOffsetFor(offset)
        switch tableAndOffset.0 {
        case .a:
            return tableA.read(at: tableAndOffset.1)
        case .b:
            return tableB.read(at: tableAndOffset.1)
        }
    }
}
