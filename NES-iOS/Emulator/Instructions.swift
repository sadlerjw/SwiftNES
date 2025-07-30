//
//  Instructions.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

protocol Instruction {
    static var sharedInstance : Self { get }
    static var opcodeReferences : [OpcodeReference] { get }
    var name : String { get }
    
    func execute(cpu: borrowing CPU)
}

extension Instruction {
    var name : String {
        String(describing: type(of: self))
    }
}

enum Instructions {
    static let all : [Instruction.Type] = [
        LDA.self, LDX.self, ADC.self, DEX.self, CLC.self, NOP.self, BNE.self
    ]
    
    struct LDA : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xA9,
                  totalBytes: 2,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.sharedInstance),
            .init(opcode: 0xA5,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0xB5,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.sharedInstance),
            .init(opcode: 0xAD,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
            .init(opcode: 0xBD,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.sharedInstance),
            .init(opcode: 0xB9,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteY.sharedInstance),
            .init(opcode: 0xA1,
                  totalBytes: 2,
                  defaultCycles: 6,
                  addsCycleIfPageCrossed: false,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectX.sharedInstance),
            .init(opcode: 0xB1,
                  totalBytes: 2,
                  defaultCycles: 5,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectY.sharedInstance),
            
        ]
        
        func execute(cpu: borrowing CPU) {
            cpu.a = cpu.fetchedData
            
            cpu.status.setZ(cpu.fetchedData == 0)
            cpu.status.setN(cpu.fetchedData >> 7 == 1)
        }
    }
    
    struct LDX : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xA2,
                  totalBytes: 2,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.sharedInstance),
            .init(opcode: 0xA6,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0xB6,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageY.sharedInstance),
            .init(opcode: 0xAE,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
            .init(opcode: 0xBE,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteY.sharedInstance),
        ]
        
        func execute(cpu: borrowing CPU) {
            cpu.x = cpu.fetchedData
            
            cpu.status.setZ(cpu.fetchedData == 0)
            cpu.status.setN(cpu.fetchedData >> 7 == 1)
        }
    }
    
    struct ADC : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x69,
                  totalBytes: 2,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.sharedInstance),
            .init(opcode: 0x65,
                  totalBytes: 2,
                  defaultCycles: 3,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPage.sharedInstance),
            .init(opcode: 0x75,
                  totalBytes: 2,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.ZeroPageX.sharedInstance),
            .init(opcode: 0x6D,
                  totalBytes: 3,
                  defaultCycles: 4,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Absolute.sharedInstance),
            .init(opcode: 0x7D,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteX.sharedInstance),
            .init(opcode: 0x79,
                  totalBytes: 3,
                  defaultCycles: 4,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.AbsoluteY.sharedInstance),
            .init(opcode: 0x61,
                  totalBytes: 2,
                  defaultCycles: 6,
                  addsCycleIfPageCrossed: false,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectX.sharedInstance),
            .init(opcode: 0x71,
                  totalBytes: 2,
                  defaultCycles: 5,
                  addsCycleIfPageCrossed: true,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.IndirectY.sharedInstance),
        ]
        
        func execute(cpu: borrowing CPU) {
            let result = UInt16(cpu.a) &+ UInt16(cpu.fetchedData) &+ UInt16(cpu.status.contains(.c) ? 1 : 0)
            
            cpu.status.setC(result > 255)
            
            let truncatedResult = UInt8(result & 0xFF)
            
            cpu.status.setZ(truncatedResult == 0)
            cpu.status.setO(((result ^ UInt16(cpu.a)) & (result ^ UInt16(cpu.fetchedData)) & 0x80) != UInt16(0))
            cpu.status.setN(truncatedResult >> 7 == 1)
            
            cpu.a = truncatedResult
        }
    }
    
    struct DEX : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xCA,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        func execute(cpu: borrowing CPU) {
            cpu.x &-= 1
            cpu.status.setZ(cpu.x == 0)
            cpu.status.setN(cpu.x >> 7 == 1)
        }
    }
    
    struct CLC : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0x18,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        func execute(cpu: borrowing CPU) {
            cpu.status.setC(false)
        }
    }
    
    struct NOP : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xEA,
                  totalBytes: 1,
                  defaultCycles: 2,
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Implied.sharedInstance),
        ]
        
        func execute(cpu: borrowing CPU) {
            // no-op!
        }
    }
    
    struct BNE : Instruction {
        static let sharedInstance = Self.init()
        
        static let opcodeReferences : [OpcodeReference] = [
            .init(opcode: 0xD0,
                  totalBytes: 1,
                  defaultCycles: 2,
                  addsCycleIfPageCrossed: false, // technically true - but since it's a relative signed 8-bit integer, we'll deal with it manually in `execute`
                  instruction: Self.sharedInstance,
                  addressingMode: AddressingModes.Immediate.sharedInstance),
        ]
        
        func execute(cpu: borrowing CPU) {
            let willBranch = !cpu.status.contains(.z)
            
            if willBranch {
                cpu.cyclesBeforeNextInstruction += 1
                let offset = Int8(bitPattern: cpu.fetchedData)
                let newPC : UInt16 = UInt16(Int32(cpu.pc) + Int32(offset))
                
                let pageCrossed : Bool = (cpu.pc & 0xFF00) != (newPC & 0xFF00)
                
                if pageCrossed {
                    cpu.cyclesBeforeNextInstruction += 1
                }
                
                cpu.pc = newPC
            }
        }
    }
}
