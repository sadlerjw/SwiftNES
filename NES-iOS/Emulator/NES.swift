//
//  NES.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-29.
//

import Observation

typealias Address = UInt16
typealias Byte = UInt8

@Observable
class NES {
    let mainBus = MainBus()
    let cpu : CPU
    let ram : RAM<0xFFFF>
    
    init () {
        ram = RAM<0xFFFF>()
        mainBus.addDevice(ram, at: 0x0000)
        cpu = CPU(bus: mainBus)
    }
    
    func addDebugProgramToRam() {
        /*
         LDA #0
         LDX #3
         CLC

         loop:
         ADC #9
         DEX
         BNE loop

         NOP
         NOP
         NOP
         */
        let program: [Byte] = [
            0xA9, 0x00, 0xA2, 0x03, 0x18, 0x69, 0x09, 0xCA,
            0xD0, 0xFB, 0xEA, 0xEA, 0xEA
        ]
        
        var offset : BusDevice.Offset = 0x8000
        for byte in program {
            ram.write(byte, at: offset)
            offset += 1
        }
        
        // Write reset vector (pointing at 0x8000, the beginning of our program)
        ram.write(0x00, at: 0xFFFC)
        ram.write(0x80, at: 0xFFFD)
    }
    
    func startup() {
        cpu.startup()
    }
    
    func reset() {
        cpu.reset()
    }
    
    func tick() {
        cpu.tick()
    }
    
    func stepCPU() {
        if cpu.cyclesBeforeNextInstruction == 0 {
            tick()
        }
        while cpu.cyclesBeforeNextInstruction > 0 {
            tick()
        }
    }
}
