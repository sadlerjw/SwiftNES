//
//  NES.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-02.
//


import Dispatch
import Observation
import Foundation

typealias Address = UInt16
typealias Byte = UInt8

extension Address {
    var hexCode : String {
        String(format: "$%04X", self)
    }
}

extension Byte {
    var hexCode : String {
        String(format: "$%02X", self)
    }
}

class NES {
    enum MainBusAddresses {
        static let ramStart : Address = 0x0000
        
        static let PPUCTRL : Address = 0x2000
        static let PPUMASK : Address = 0x2001
        static let PPUSTATUS : Address = 0x2002
        static let OAMADDR : Address = 0x2003
        static let OAMDATA : Address = 0x2004
        static let PPUSCROLL : Address = 0x2005
        static let PPUADDR : Address = 0x2006
        static let PPUDATA : Address = 0x2007
        
        static let apuPulse1Start : Address = 0x4000
        static let apuPulse2Start : Address = 0x4004
        static let apuTriangleStart : Address = 0x4008
        static let apuNoiseStart : Address = 0x400C
        static let apuDMCStart : Address = 0x4010
        
        static let OAMDMA : Address = 0x4014
        
        static let apuSoundStatus : Address = 0x4015
        static let controller1 : Address = 0x4016
        static let controller2 : Address = 0x4017       // In read only
        static let apuFrameCounter : Address = 0x4017 // In write only
        
        static let cartridgeStart : Address = 0x4020
        
        static let nmiVector : Address = 0xFFFA
        static let resetVector : Address = 0xFFFC
        static let brkVector : Address = 0xFFFE
        
        static let lastAddress : UInt16 = 0xFFFF
    }
    
    enum PPUBusAddresses {
        static let cartridgeStart : Address = 0x0000
        static let patternTable0Start : Address = 0x0000
        static let patternTable1Start : Address = 0x1000
        static let nametable0Start : Address = 0x2000
        static let attributeTable0Start : Address = 0x23C0
        static let nametable1Start : Address = 0x2400
        static let attributeTable1Start : Address = 0x26C0
        static let nametable2Start : Address = 0x2800
        static let attributeTable2Start : Address = 0x2BC0
        static let nametable3Start : Address = 0x2C00
        static let attributetable3Start : Address = 0x2FC0
        static let paletteRAMIndexesStart : Address = 0x3F00
        
        static let lastAddress : UInt16 = 0x3FFF
    }
    
    let mainBus = Bus()
    let ppuBus = Bus()
    
    let cpu : CPU
    let ppu : PPU
    let oamDMA : OAMDMA

    private(set) var clockCount : UInt = 0
    
    /// Sets up a full NES emulator stack. `startup()` should be called before use.
    /// - Parameter allRam: Set up a huge bank of RAM on the main bus instead of mapping devices.
    ///                         Should be used only for unit tests or debugging.
    init(allRAM: Bool = false) {
        if allRAM {
            let ram: any Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x10000>()
                } else {
                    return RAM_legacy(length: 0x10000)
                }
            }()
            mainBus.addDevice(ram, at: 0x0000)
            
            let ppuRAM: any Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x4000>()
                } else {
                    return RAM_legacy(length: 0x4000)
                  }
            }()
            ppuBus.addDevice(ppuRAM, at: 0x0000)
        } else {
            // MARK: CPU Bus
            let ram: any Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x800>()
                } else {
                    return RAM_legacy(length: 0x800)
                  }
            }()
            let ramMirror = Mirror(mirroring: ram, times: 3)
            mainBus.addDevice(ramMirror, at: MainBusAddresses.ramStart)
            
            // PPU registers normally get mapped here, but first we have to
            // create the PPU! So it happens later.
            
            let apuRegisters: any Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x14>()
                } else {
                    return RAM_legacy(length: 0x14)
                  }
            }()  // TODO: use a real APU
            mainBus.addDevice(apuRegisters, at: MainBusAddresses.apuPulse1Start)
            
            // OAM DMA at 0x4014 comes here but it needs a reference to the CPU so we add it to the bus later below.
            
            // This is pretty confusing...maybe ALL of it should be moved to the APU and have
            // it vend another addressable for it
            let joystickAndIRQAndAPUFrameCounter = ClosureAddressable(length: 3,
                                                                      name: "Joystick / IRQ / APU Frame Counter") { value, offset in
                switch offset {
                case 0:
                    // TODO: APU enable/disable sound channels https://www.nesdev.org/wiki/APU#Status_($4015)
                    break
                case 1:
                    // TODO: output to both controllers https://www.nesdev.org/wiki/Input_devices#Usage_of_port_pins_by_hardware_type
                    break
                case 2:
                    // TODO: APU frame counter control https://www.nesdev.org/wiki/APU_Frame_Counter
                    break
                default:
                    fatalError("Received impossible offset \(offset) in Joystick/IRQ/FrameCounter addressable")
                }
            } read: { offset in
                switch offset {
                case 0:
                    // TODO: APU interrupt and sound channel status https://www.nesdev.org/wiki/APU#Status_($4015)
                    return 0
                case 1:
                    // TODO: read controller 1
                    return 0
                case 2:
                    // TODO: read controller 2
                    return 0
                default:
                    fatalError("Received impossible offset \(offset) in Joystick/IRQ/FrameCounter addressable")
                }
            }
            
            mainBus.addDevice(joystickAndIRQAndAPUFrameCounter, at: MainBusAddresses.apuSoundStatus)
            
            // $4018–$401F are for CPU test mode, so unused for us.
            
            let cartridgeCPUMap: any Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0xBFE0>()
                } else {
                    return RAM_legacy(length: 0xBFE0)
                  }
            }()       // TODO: real cartridges and mappers
            mainBus.addDevice(cartridgeCPUMap, at: MainBusAddresses.cartridgeStart)
            
            // MARK: PPU Bus
            let cartridgePPUMap: any Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x3F00>()
                } else {
                    return RAM_legacy(length: 0x3F00)
                  }
            }()       // TODO: real cartridges and mappers
            ppuBus.addDevice(cartridgePPUMap, at: PPUBusAddresses.cartridgeStart)
            
            let paletteRam: any Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x0020>()
                } else {
                    return RAM_legacy(length: 0x0020)
                  }
            }()
            let paletteMirror = Mirror(mirroring: paletteRam, times: 7)
            ppuBus.addDevice(paletteMirror, at: PPUBusAddresses.paletteRAMIndexesStart)
        }
        
        cpu = CPU(bus: mainBus)
        ppu = PPU(bus: ppuBus)
        oamDMA = OAMDMA(cpu: cpu)
        
        if !allRAM {
            let ppuRegisters = ppu.addressableRegisters
            let ppuMirror = Mirror(mirroring: ppuRegisters, times: 1023)
            mainBus.addDevice(ppuMirror, at: MainBusAddresses.PPUCTRL)
            
            mainBus.addDevice(oamDMA, at: MainBusAddresses.OAMDMA)
        }
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
        
        var offset : Addressable.Offset = 0x8000
        for byte in program {
            mainBus.write(byte, at: offset)
            offset += 1
        }
        
        // Write reset vector (pointing at 0x8000, the beginning of our program)
        mainBus.write(0x00, at: MainBusAddresses.resetVector)
        mainBus.write(0x80, at: MainBusAddresses.resetVector + 1)
    }
    
    func startup() {
        cpu.startup()
    }
    
    func reset() {
        cpu.reset()
    }
    
    func tick() {
        if clockCount % 3 == 0 {
            cpu.tick()
            oamDMA.tick()
            clockCount = 0
        }

        ppu.tick()
        clockCount += 1
    }
    
    func tickCPU() {
        while clockCount % 3 != 0 {
            tick()
        }
        tick()
    }
    
    func stepCPU() {
        if cpu.cyclesBeforeNextInstruction == 0 {
            tickCPU()
        }
        while cpu.cyclesBeforeNextInstruction > 0 {
            tickCPU()
        }
    }
    
    func stepFrame() {
        while ppu.status.contains(.vblank) {
            tick()
        }
        while !ppu.status.contains(.vblank) {
            tick()
        }
    }
}
