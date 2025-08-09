//
//  INESFile.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-06.
//

import Foundation

struct INESFile {
    enum InvalidFileError : Error {
        case tooShortToContainHeader
        case shorterThanHeaderIndicates
        case invalidHeader
    }
    
    enum Mirroring : Int {
        case horizontal = 0
        case vertical = 1
    }
    
    struct Header {
        struct Flags6 {
            var nametableMirroring: Mirroring
            var containsPersistentMemory: Bool
            var containsTrainer: Bool
            var alternativeNametableLayout: Bool
            var mapperNumberLowerNybble: Byte   // Only 4 bits
            
            init(byte: Byte) {
                nametableMirroring = .init(rawValue: Int(byte & (1 << 0)))!
                containsPersistentMemory = (byte & (1 << 1)) != 0
                containsTrainer = (byte & (1 << 2)) != 0
                alternativeNametableLayout = (byte & (1 << 3)) != 0
                mapperNumberLowerNybble = (byte & 0xF0) >> 4
            }
        }
        
        struct Flags7 {
            var isVSUnisystem: Bool
            var isPlayChoice10: Bool
            var otherFlagsAreINES2: Bool
            var mapperNumberUpperNybble: Byte   // Only 4 bits
            
            init(byte: Byte) {
                isVSUnisystem = (byte & (1 << 0)) != 0
                isPlayChoice10 = (byte & (1 << 1)) != 0
                otherFlagsAreINES2 = (byte & 0x0C) == 0x0C
                mapperNumberUpperNybble = (byte & 0xF0) >> 4
            }
        }
        
        struct Flags8 {
            var prgRAMSize: Byte
            
            init(byte: Byte) {
                prgRAMSize = byte
            }
        }
        
        struct Flags9 {
            enum TVSystem {
                case NTSC
                case PAL
            }
            
            var tvSystem: TVSystem
            
            init(byte: Byte) {
                tvSystem = (byte & 1) > 0 ? .PAL : .NTSC
            }
        }
        
        static let expectedHeader = Data([0x4E, 0x45, 0x53, 0x1A])
        
        var prgSizeKB: Int
        var chrSizeKB: Int
        
        var flags6: Flags6
        var flags7: Flags7
        var flags8: Flags8
        var flags9: Flags9
        
        var mapperNumber: Byte {
            return flags7.mapperNumberUpperNybble << 4 | flags6.mapperNumberLowerNybble
        }
        
        init(data: Data) throws {
            guard data[0...3] == Self.expectedHeader else {
                throw InvalidFileError.invalidHeader
            }
            
            prgSizeKB = Int(data[4]) * 16
            chrSizeKB = Int(data[5]) * 8
            flags6 = .init(byte: data[6])
            flags7 = .init(byte: data[7])
            flags8 = .init(byte: data[8])
            flags9 = .init(byte: data[9])
        }
    }

    var header: Header
    var prgROM: Array<Byte>
    var chrROM: Array<Byte>
    
    init(data: Data) throws {
        guard data.count > 15 else {
            throw InvalidFileError.tooShortToContainHeader
        }
        
        header = try Header(data: data[0 ... 15])
        
        let trainerLength = header.flags6.containsTrainer ? 512 : 0
        
        guard data.count >= 16 + trainerLength + (header.prgSizeKB + header.chrSizeKB) * 1024 else {
            throw InvalidFileError.shorterThanHeaderIndicates
        }
        
        let prgEndIndex = 16 + trainerLength + header.prgSizeKB * 1024 - 1
        let chrEndIndex = prgEndIndex + header.chrSizeKB * 1024
        prgROM = Array(data[16 ... prgEndIndex])
        chrROM = Array(data[prgEndIndex + 1 ... chrEndIndex])
    }
}
