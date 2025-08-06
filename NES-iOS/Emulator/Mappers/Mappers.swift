//
//  Mappers.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-06.
//

protocol Mapper {
    var cpuAddressSpace: any MapperCPUAddressSpace { get }
    var ppuAddressSpace: any MapperPPUAddressSpace { get }
    
    init(iNESFile: INESFile)
}

/// Almost identical to `Addressable` but `read` returns an optional.
/// This is because a catridge can choose to (or not to) return some of its
/// own data for _any_ address, not just stuff that's normally memory
/// mapped to the cartridge.
/// Mappers operate over the entire address space, so they take the global
/// address. (Addressables take offsets relative to the Addressable's start
/// address in the global address space)
protocol MapperAddressSpace {
    var length : Int { get }
    var name : String { get }
    
    /// Returns true if the mapper handled this write; false if it should be handled by the bus
    func write(_ value: Byte, at address: Address) -> Bool
    /// Returns nil if nothing in the cartridge is mapped at this address
    func read(at address: Address) -> Byte?
}

protocol MapperCPUAddressSpace : MapperAddressSpace {}
extension MapperCPUAddressSpace {
    var length: Int { 0x10000 }
}

protocol MapperPPUAddressSpace : MapperAddressSpace {}
extension MapperPPUAddressSpace {
    var length: Int { 0x4000 }
}

enum Mappers {
    static let mappers: [Int: any Mapper.Type] = [
        0: Mapper0.self
    ]
}
