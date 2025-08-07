//
//  CPU.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

import Foundation
import Observation

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
        
        var debugDescription: String {
            return "\(contains(.n) ? "N" : "n") \(contains(.o) ? "O" : "o") \(contains(.one_unused) ? "1" : "_") \(contains(.b) ? "B" : "b") \(contains(.d) ? "D" : "d") \(contains(.i) ? "I" : "i") \(contains(.z) ? "Z" : "z") \(contains(.c) ? "C" : "c")"
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
    
    struct Stack {
        unowned let bus : Bus
        let baseAddress: Address = 0x0100
        var stackPointer: Byte = 0
        
        @inline(__always)
        mutating func push(_ value: Byte) {
            bus.write(value, at: baseAddress + Address(stackPointer))
            stackPointer &-= 1
        }
        
        @inline(__always)
        mutating func push(_ value: Address) {
            push(value.high)
            push(value.low)
        }
        
        @inline(__always)
        mutating func popByte() -> Byte {
            stackPointer &+= 1
            return bus.read(baseAddress + Address(stackPointer))
        }
        
        @inline(__always) 
        mutating func popAddress() -> Address {
            let low = popByte()
            let high = popByte()
            return Address(low: low, high: high)
        }
        
        func peekByte(offset: Byte = 0) -> Byte {
            return bus.read(baseAddress + Address(stackPointer &+ 1 &+ offset))
        }
        
        mutating func peekAddress() -> Address {
            let low = peekByte(offset: 0)
            let high = peekByte(offset: 1)
            return Address(low: low, high: high)
        }
    }

    var a: UInt8 = 0
    var x: UInt8 = 0
    var y: UInt8 = 0
    
    var pc: UInt16 = 0
    var stack : Stack
    var status: StatusRegister = .i
    
    var fetchedData: UInt8 = 0
    var fetchedFromAddress: Address? = nil
    var cyclesBeforeNextInstruction = 0
    
    var interruptsEnabled: Bool = false
    var changingInterruptsEnabledShouldBeDelayed = false
    
    private(set) var isHalted = false
    
    unowned let bus : Bus
    
    init(bus: Bus) {
        self.bus = bus
        self.stack = Stack(bus: bus)
    }
    
    func startup() {
        reset()
    }
    
    func reset() {
        let low = bus.read(NES.MainBusAddresses.resetVector)
        let high = bus.read(NES.MainBusAddresses.resetVector + 1)
        pc = UInt16(low) | (UInt16(high) << 8)
        stack.stackPointer &-= 3    // Means on startup it starts at 0x00 - 3 = 0xFD
        status.insert(.i)
        
        fetchedData = 0
        fetchedFromAddress = nil
        cyclesBeforeNextInstruction = 0
    }
    
    func requestHalt() {
        isHalted = true
    }
    
    func unHalt() {
        isHalted = false
    }
    
    func tick() {
        guard !isHalted else { return }
        
        defer {
            if cyclesBeforeNextInstruction > 0 {
            cyclesBeforeNextInstruction -= 1
        }
        }
        
        guard cyclesBeforeNextInstruction == 0 else { return }
        
        fetchedData = 0
        fetchedFromAddress = nil
        
        let interruptsEnabledAfterExecution : Bool? = changingInterruptsEnabledShouldBeDelayed ? status.contains(.i) : nil
        changingInterruptsEnabledShouldBeDelayed = false
        
        let opcode = bus.read(pc)
        
        guard let opcodeReference = OpcodeReference.lookupTable[opcode] else {
            print("Invalid opcode: \(opcode)")
            return
        }
        
        printout(opcodeReference: opcodeReference)
        
        pc += 1
        
        cyclesBeforeNextInstruction = opcodeReference.defaultCycles
        
        let addressingMode = opcodeReference.addressingMode
        addressingMode.fetch(cpu: self, addingCycleIfPageCrossed: opcodeReference.addsCycleIfPageCrossed)
        
        let instruction = opcodeReference.instruction
        let readModifyWriteResult = instruction.execute(cpu: self)
        
        if let interruptsEnabledAfterExecution {
            interruptsEnabled = interruptsEnabledAfterExecution
        }
        
        if !changingInterruptsEnabledShouldBeDelayed {
            interruptsEnabled = status.contains(.i)
        }
        
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
    
    func printout(opcodeReference: OpcodeReference) {
        func formatHex(_ byte: Byte) -> String {
            String(format: "%02X", byte)
        }
        func formatHex(_ address: Address) -> String {
            String(format: "%04X", address)
        }
        
        let address = String(format: "%04X", pc)
        
        var bytes = formatHex(opcodeReference.opcode)
        for i in 1 ..< opcodeReference.totalBytes {
            bytes = bytes + " " + formatHex(bus.read(pc + Address(i)))
        }
        bytes = bytes.padding(toLength: 8, withPad: " ", startingAt: 0)
        
        let firstHalf = "\(address)  \(bytes)  \(opcodeReference.instruction.name)".padding(toLength: 48, withPad: " ", startingAt: 0)
        
        let secondHalf = "A:\(formatHex(a)) X:\(formatHex(x)) Y:\(formatHex(y)) P:\(formatHex(status.rawValue)) SP:\(formatHex(stack.stackPointer))"
        
        print("\(firstHalf)\(secondHalf)")
    }
}


