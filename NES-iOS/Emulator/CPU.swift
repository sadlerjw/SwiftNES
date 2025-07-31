//
//  CPU.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

import Foundation
import Observation

@Observable
class CPU {
    struct StatusRegister : OptionSet {
        private static let alwaysOneRawValue : UInt8 = 1 << 5
        
        private var internalRawValue: UInt8
        
        var rawValue: UInt8 {
            set {
                internalRawValue = newValue | Self.alwaysOneRawValue
            }
            get {
                return internalRawValue
            }
        }
        
        static let c = StatusRegister(rawValue: 1 << 0)
        static let z = StatusRegister(rawValue: 1 << 1)
        static let i = StatusRegister(rawValue: 1 << 2)
        static let d = StatusRegister(rawValue: 1 << 3)
        static let b = StatusRegister(rawValue: 1 << 4)
        static let one_unused = StatusRegister(rawValue: alwaysOneRawValue)
        static let o = StatusRegister(rawValue: 1 << 6)
        static let n = StatusRegister(rawValue: 1 << 7)
        
        init(rawValue: UInt8) {
            internalRawValue = rawValue | Self.alwaysOneRawValue
        }
        
        mutating func setC(_ c: Bool) {
            if c {
                self.insert(.c)
            } else {
                self.remove(.c)
            }
        }
        
        mutating func setZ(_ z: Bool) {
            if z {
                self.insert(.z)
            } else {
                self.remove(.z)
            }
        }
        
        mutating func setI(_ i: Bool) {
            if i {
                self.insert(.i)
            } else {
                self.remove(.i)
            }
        }
        
        mutating func setD(_ d: Bool) {
            if d {
                self.insert(.d)
            } else {
                self.remove(.d)
            }
        }
        
        mutating func setB(_ b: Bool) {
            if b {
                self.insert(.b)
            } else {
                self.remove(.b)
            }
        }
        
        mutating func setO(_ o: Bool) {
            if o {
                self.insert(.o)
            } else {
                self.remove(.o)
            }
        }
        
        mutating func setN(_ n: Bool) {
            if n {
                self.insert(.n)
            } else {
                self.remove(.n)
            }
        }
    }

    var a: UInt8 = 0
    var x: UInt8 = 0
    var y: UInt8 = 0
    
    var pc: UInt16 = 0xFFFC
    var stackPointer: UInt8 = 0
    var status: StatusRegister = .i
    
    var fetchedData: UInt8 = 0
    var cyclesBeforeNextInstruction = 0
    
    unowned let bus : MainBus
    
    init(bus: MainBus) {
        self.bus = bus
    }
    
    func startup() {
        reset()
    }
    
    func reset() {
        let low = bus.read(0xFFFC)
        let high = bus.read(0xFFFD)
        pc = UInt16(low) | (UInt16(high) << 8)
        stackPointer &-= 3
        status.insert(.i)
        
        fetchedData = 0
        cyclesBeforeNextInstruction = 0
    }
    
    func tick() {
        defer {
            cyclesBeforeNextInstruction -= 1
        }
        
        guard cyclesBeforeNextInstruction == 0 else { return }
        
        let opcode = bus.read(pc)
        pc += 1
        
        guard let opcodeReference = OpcodeReference.lookupTable[opcode] else {
            print("Invalid opcode: \(opcode)")
            return
        }
        
        cyclesBeforeNextInstruction = opcodeReference.defaultCycles
        
        let addressingMode = opcodeReference.addressingMode
        addressingMode.fetch(cpu: self, addingCycleIfPageCrossed: opcodeReference.addsCycleIfPageCrossed)
        
        let instruction = opcodeReference.instruction
        let readModifyWriteResult = instruction.execute(cpu: self)
        
        if let readModifyWriteResult {
            // First we write back the original value, then the updated one.
            // This comes from a note from https://www.nesdev.org/wiki/Instruction_reference#ASL:
            // > This is a read-modify-write instruction, meaning that its
            // > addressing modes that operate on memory first write the
            // > original value back to memory before the modified value.
            // > This extra write can matter if targeting a hardware register.
            addressingMode.write(fetchedData, cpu: self)
            addressingMode.write(readModifyWriteResult, cpu: self)
        }
    }
}


