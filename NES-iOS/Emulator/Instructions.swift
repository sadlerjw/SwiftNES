//
//  Instructions.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

protocol Instruction {
    typealias ReadModifyWriteResult = Byte
    
    static var sharedInstance : Self { get }
    static var opcodeReferences : [OpcodeReference] { get }
    var name : String { get }
    
    @discardableResult
    func execute(cpu: borrowing CPU) -> ReadModifyWriteResult?
}

extension Instruction {
    var name : String {
        String(describing: type(of: self))
    }
}

enum Instructions {
    static let all : [Instruction.Type] = [
        AND.self, ASL.self, BCC.self, BCS.self, BEQ.self, BIT.self, BMI.self, BNE.self, BPL.self,
        LDA.self, LDX.self, ADC.self, DEX.self, CLC.self, NOP.self
    ]
    
    // Namespace for the various instructions
    // See the files in the Instructions folder
    // for implementations.
    
    struct BranchInstructionCommonLogic {
        static func performBranch(cpu: borrowing CPU) {
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
