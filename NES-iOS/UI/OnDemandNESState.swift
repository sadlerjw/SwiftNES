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
        
        var topOfStack: Byte
        var topOfStackNext: Byte
        
        init() {
            a = 0
            x = 0
            y = 0
            pc = 0
            
            status = .init()
            stackPointer = 0
            
            topOfStack = 0
            topOfStackNext = 0
        }
        
        init(from nes: NES) {
            self.a = nes.cpu.a
            self.x = nes.cpu.x
            self.y = nes.cpu.y
            
            self.pc = nes.cpu.pc
            
            self.status = nes.cpu.status
            self.stackPointer = nes.cpu.stack.stackPointer
            
            self.topOfStack = nes.cpu.stack.peekByte(offset: 0)
            self.topOfStackNext = nes.cpu.stack.peekByte(offset: 1)
        }
        
        mutating func update(from nes: NES) {
            self.a = nes.cpu.a
            self.x = nes.cpu.x
            self.y = nes.cpu.y
            
            self.pc = nes.cpu.pc
            
            self.status = nes.cpu.status
            self.stackPointer = nes.cpu.stack.stackPointer
            
            self.topOfStack = nes.cpu.stack.peekByte(offset: 0)
            self.topOfStackNext = nes.cpu.stack.peekByte(offset: 1)
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
    
    private(set) var addressesContainingPC : Range<Int> = 0x8000 ..< 0x8010
    var addressSpaceSliceContainingPC: [EnumeratedByte] {
        let range = addressesContainingPC
        return addressSpace[range].enumerated().map { EnumeratedByte(index: $0.offset + range.lowerBound, element: $0.element)}
    }
    
    init() {
        cpu = .init()
    }
    
    init(nes: NES) {
        self.nes = nes
        self.cpu = .init(from: nes)
        for i in 0 ... 0xFFFF {
            addressSpace[i] = nes.mainBus.debugRead(Address(i))
        }
        
        if !addressesContainingPC.contains(Int(cpu.pc)) {
            let startAddress = Int(cpu.pc - cpu.pc % 0x0010)
            addressesContainingPC = startAddress ..< startAddress + 0x0010
        }
    }
    
    func update(from nes: NES) {
        cpu = .init(from: nes)
        
        if !addressesContainingPC.contains(Int(cpu.pc)) {
            let startAddress = Int(cpu.pc - cpu.pc % 0x0010)
            addressesContainingPC = startAddress ..< startAddress + 0x0010
        }
        
        for i in addressesContainingPC {
            addressSpace[i] = nes.mainBus.debugRead(Address(i))
        }
    }
}
