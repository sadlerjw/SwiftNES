//
//  OpcodeReference.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//


struct OpcodeReference {
    var opcode : UInt8
    var totalBytes : Int
    var defaultCycles : Int = 2
    var addsCycleIfPageCrossed : Bool = false
    var instruction : Instruction
    var addressingMode : any AddressingMode.Type
    
    static let lookupTable : [UInt8 : OpcodeReference] = {
        var table : [UInt8 : OpcodeReference] = [:]
        
        for instruction in Instructions.all {
            for opcodeRef in instruction.opcodeReferences {
                assert(table.keys.contains(opcodeRef.opcode) == false)
                
                table[opcodeRef.opcode] = opcodeRef
            }
        }
        
        return table
    }()
}
