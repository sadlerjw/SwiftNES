//
//  Mirror.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-01.
//

class Mirror : Addressable {
    let addressable : any Addressable
    let numberOfMirrors : UInt
    
    var length: Int {
        return addressable.length * (1 + Int(numberOfMirrors))
    }
    
    var name : String {
        return "Mirror(\(addressable.name), \(1 + numberOfMirrors)x)"
    }
    
    /// Mirrors an `Addressable` a certain number of times
    /// - Parameters:
    ///   - addressable: The `Addressable` to mirror
    ///   - times: The number of times the `Addressable` should be mirrored. Passing `0` is
    ///                          the same as using the `Addressable` as-is.
    init(mirroring addressable: any Addressable, times: UInt) {
        self.addressable = addressable
        self.numberOfMirrors = times
    }

    private func unMirrorOffset(_ address: Offset) -> Offset {
        return address % Offset(addressable.length)
    }
    
    func write(_ value: Byte, at offset: Offset) {
        addressable.write(value, at: unMirrorOffset(offset))
    }
    
    func read(at offset: Offset) -> Byte {
        return addressable.read(at: unMirrorOffset(offset))
    }
}
