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
        AND.self, LDA.self, LDX.self, ADC.self, DEX.self, CLC.self, NOP.self, BNE.self
    ]
    
    // Namespace for the various instructions
    // See the files in the Instructions folder
    // for implementations.
}
