//
//  Bus.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//


class Bus {
    private struct Entry {
        var start : Address
        var device : any Addressable
        
        var range : ClosedRange<Address> { start ... (start + Address(device.length - 1)) }
    }
    
    private var deviceEntries = [Entry]()
    var cartridgeMapper : (any MapperAddressSpace)?
    
    @inline(__always)
    private func deviceEntry(at address: Address) -> Entry? {
        for entry in deviceEntries {
            if address >= entry.start && address < Int(entry.start) + entry.device.length {
                return entry
            }
        }
        return nil
    }
    
    @inline(__always)
    func write(_ value: Byte, at address: Address) {
        if let cartridgeMapper,
           cartridgeMapper.write(value, at: address) {
            return
        }
        
        guard let entry = deviceEntry(at: address) else { return }
        let offset : Addressable.Offset = address - entry.start
        entry.device.write(value, at: offset)
    }
    
    @inline(__always)
    func read(_ address: Address) -> Byte {
        if let cartridgeMapper,
           let value = cartridgeMapper.read(at: address) {
            return value
        }
        
        guard let entry = deviceEntry(at: address) else { fatalError("No device for address \(address)") }
        let offset : Addressable.Offset = address - entry.start
        return entry.device.read(at: offset)
    }
    
    func debugRead(_ address: Address) -> Byte {
        if let cartridgeMapper,
           let value = cartridgeMapper.read(at: address) {
            return value
        }
        
        guard let entry = deviceEntry(at: address) else { return 0 }
        let offset : Addressable.Offset = address - entry.start
        return entry.device.read(at: offset)
    }
    
    func addDevice(_ device: any Addressable, at startAddress: Address) {
        let newEntry = Entry(start: startAddress, device: device)
        
        for entry in deviceEntries {
            guard !entry.range.overlaps(newEntry.range) else { fatalError("New device \(device.name) overlaps with existing device \(entry.device.name)")}
        }
        
        deviceEntries.append(newEntry)
    }
}
