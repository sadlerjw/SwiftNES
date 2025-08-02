//
//  Bus.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//


class Bus<Source> {
    private struct Entry {
        var start : Address
        var device : Addressable
        
        var range : ClosedRange<Address> { start ... (start + Address(device.length - 1)) }
    }
    
    private var deviceEntries = [Entry]()
    
    private func deviceEntry(at address: Address) -> Entry? {
        for entry in deviceEntries {
            if address >= entry.start && address < Int(entry.start) + entry.device.length {
                return entry
            }
        }
        return nil
    }
    
    func write(_ value: Byte, at address: Address, from source: Void) {
        guard let entry = deviceEntry(at: address) else { return }
        let offset : Addressable.Offset = address - entry.start
        entry.device.write(value, at: offset)
    }
    
    func read(_ address: Address, from source: Void) -> UInt8 {
        guard let entry = deviceEntry(at: address) else { fatalError("No device for address \(address)") }
        let offset : Addressable.Offset = address - entry.start
        return entry.device.read(at: offset)
    }
    
    func addDevice(_ device: Addressable, at startAddress: Address) {
        let newEntry = Entry(start: startAddress, device: device)
        
        for entry in deviceEntries {
            guard !entry.range.overlaps(newEntry.range) else { fatalError("New device \(device.name) overlaps with existing device \(entry.device.name)")}
        }
        
        deviceEntries.append(newEntry)
    }
}

extension Bus where Source == Void {
    func write(_ value: Byte, at address: Address) {
        self.write(value, at: address, from: ())
    }
    
    func read(_ address: Address) -> UInt8 {
        self.read(address, from: ())
    }
}


