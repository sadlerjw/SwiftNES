//
//  OnDemandNESState.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-05.
//

import Foundation
import Observation

@Observable
class OnDemandNESState {
    struct CPUState {
        var a: Byte
        var x: Byte
        var y: Byte
        
        var pc: Address

        var status: CPU.StatusRegister
        var stackPointer: Byte
        
        init() {
            a = 0
            x = 0
            y = 0
            pc = 0
            
            status = .init()
            stackPointer = 0
        }
        
        init(from nes: NES) {
            self.a = nes.cpu.a
            self.x = nes.cpu.x
            self.y = nes.cpu.y
            
            self.pc = nes.cpu.pc
            
            self.status = nes.cpu.status
            self.stackPointer = nes.cpu.stack.stackPointer
        }
        
        mutating func update(from nes: NES) {
            self.a = nes.cpu.a
            self.x = nes.cpu.x
            self.y = nes.cpu.y
            
            self.pc = nes.cpu.pc
            
            self.status = nes.cpu.status
            self.stackPointer = nes.cpu.stack.stackPointer
        }
    }
    
    struct EnumeratedByte : Identifiable {
        var index: Int
        var element: Byte
        
        var id : Int {
            return index
        }
    }
    
    private var nes: NES!
    
    private(set) var cpu: CPUState
    private(set) var addressSpace = Array<Byte>(repeating: 0, count: 0x10000)
    
    init() {
        cpu = .init()
    }
    
    init(nes: NES) {
        self.nes = nes
        self.cpu = .init(from: nes)
        for i in 0 ... 0xFFFF {
            addressSpace[i] = nes.mainBus.debugRead(Address(i))
        }
    }
    
    func identifiableAddressSpaceSlice(_ range: Range<Int>) -> [EnumeratedByte] {
        return addressSpace[range].enumerated().map { EnumeratedByte(index: $0.offset + range.lowerBound, element: $0.element)}
    }
    
    func update(from nes: NES, includingAddressSpaceRange range: Range<Int>? = nil) {
        cpu = .init(from: nes)
        if let range {
            for i in range {
                addressSpace[i] = nes.mainBus.debugRead(Address(i))
            }
        }
    }
}
