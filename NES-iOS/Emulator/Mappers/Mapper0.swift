//
//  Mapper0.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-06.
//

import Foundation

class Mapper0 : Mapper {
    class CPUAddressSpace : MapperCPUAddressSpace {
        var name: String { "Mapper0 CPU Mapping"}
        
        let iNESFile: INESFile
        var prgSize : UInt16 {
            UInt16(iNESFile.header.prgSizeKB * 1024)
        }
        
        init(iNESFile: INESFile) {
            self.iNESFile = iNESFile
        }
        
        func write(_ value: Byte, at address: Address) -> Bool {
            // Nothing writable in this mapper
            return false
        }
        
        func read(at address: Address) -> Byte? {
            if address >= 0x6000 && address < 0x8000 && iNESFile.header.flags8.prgRAMSize > 0 {
                fatalError("PRG RAM not implemented yet") // TODO: support PRG RAM
            } else if address >= 0x8000 {
                let address = address - 0x8000
                let mirroredAddress = address % prgSize
                return iNESFile.prgROM[Int(mirroredAddress)]
            }
            return nil
        }
    }
    
    class PPUAddressSpace : MapperPPUAddressSpace {
        var name: String { "Mapper0 PPU Mapping"}
        
        let iNESFile: INESFile
        var chrSize : UInt16 {
            UInt16(iNESFile.header.chrSizeKB * 1024)
        }
        
        init(iNESFile: INESFile) {
            self.iNESFile = iNESFile
        }
        
        func write(_ value: Byte, at address: Address) -> Bool {
            // Nothing writable in this mapper
            return false
        }
        
        func read(at address: Address) -> Byte? {
            if address < 0x4000 {
                let address = address % 0x2000
                if address < 0x1000 {
                    return iNESFile.chrROM[Int(address % chrSize)]
                }
            }
            return nil
        }
    }
    
    let cpuMapping : CPUAddressSpace
    let ppuMapping : PPUAddressSpace
    
    var cpuAddressSpace: any MapperCPUAddressSpace {
        cpuMapping
    }
    var ppuAddressSpace: any MapperPPUAddressSpace {
        ppuMapping
    }
    
    
    required init(iNESFile: INESFile) {
        self.cpuMapping = .init(iNESFile: iNESFile)
        self.ppuMapping = .init(iNESFile: iNESFile)
    }
    
}
