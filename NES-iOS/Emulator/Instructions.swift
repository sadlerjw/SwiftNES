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
    
    func execute(cpu: borrowing CPU) -> ReadModifyWriteResult?
}

extension Instruction {
    var name : String {
        String(describing: type(of: self))
    }
}

enum Instructions {
    static let all : [Instruction.Type] = [
        AND.self, ADC.self, ASL.self, BCC.self, BCS.self, BEQ.self, BIT.self, BMI.self, BNE.self, BPL.self,
        BRK.self, BVC.self, BVS.self, CLC.self, CLD.self, CLI.self, CLV.self, CMP.self, CPX.self, CPY.self,
        DEC.self, DEX.self, DEY.self, EOR.self, INC.self, INX.self, INY.self, JMP.self, JSR.self, LDA.self,
        LDX.self, LDY.self, LSR.self, NOP.self, ORA.self, PHA.self, PHP.self, PLA.self, PLP.self, ROL.self,
        ROR.self, RTI.self,
    ]
    
    // Namespace for the various instructions
    // See the files in the Instructions folder
    // for implementations.
}
