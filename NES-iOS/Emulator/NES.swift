//
//  NES.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-02.
//


import Observation

typealias Address = UInt16
typealias Byte = UInt8

@Observable
class NES {
    let mainBus = Bus()
    let ppuBus = Bus()
    
    let cpu : CPU
    let ppu : PPU
    let oamDMA : OAMDMA
    
    /// Sets up a full NES emulator stack. `startup()` should be called before use.
    /// - Parameter allRam: Set up a huge bank of RAM on the main bus instead of mapping devices.
    ///                         Should be used only for unit tests or debugging.
    init(allRAM: Bool = false) {
        if allRAM {
            let ram: Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x10000>()
                } else {
                    return RAM_legacy(length: 0x10000)
                }
            }()
            mainBus.addDevice(ram, at: 0x0000)
            
            let ppuRAM: Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x4000>()
                } else {
                    return RAM_legacy(length: 0x4000)
                  }
            }()
            ppuBus.addDevice(ppuRAM, at: 0x0000)
        } else {
            // MARK: CPU Bus
            let ram: Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x800>()
                } else {
                    return RAM_legacy(length: 0x800)
                  }
            }()
            let ramMirror = Mirror(mirroring: ram, times: 3)
            mainBus.addDevice(ramMirror, at: 0x0000)
            
            // PPU registers normally get mapped here, but first we have to
            // create the PPU! So it happens later.
            
            let apuRegisters: Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x14>()
                } else {
                    return RAM_legacy(length: 0x14)
                  }
            }()  // TODO: use a real APU
            mainBus.addDevice(apuRegisters, at: 0x4000)
            
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
            
            mainBus.addDevice(joystickAndIRQAndAPUFrameCounter, at: 0x4015)
            
            // $4018–$401F are for CPU test mode, so unused for us.
            
            let cartridgeCPUMap: Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0xBFE0>()
                } else {
                    return RAM_legacy(length: 0xBFE0)
                  }
            }()       // TODO: real cartridges and mappers
            mainBus.addDevice(cartridgeCPUMap, at: 0x4020)
            
            // MARK: PPU Bus
            let cartridgePPUMap: Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x3F00>()
                } else {
                    return RAM_legacy(length: 0x3F00)
                  }
            }()       // TODO: real cartridges and mappers
            ppuBus.addDevice(cartridgePPUMap, at: 0x0000)
            
            let paletteRam: Addressable = {
                if #available(iOS 26.0, *) {
                    return RAM_26<0x0020>()
                } else {
                    return RAM_legacy(length: 0x0020)
                  }
            }()
            let paletteMirror = Mirror(mirroring: paletteRam, times: 7)
            ppuBus.addDevice(paletteMirror, at: 0x3F00)
        }
        
        cpu = CPU(bus: mainBus)
        ppu = PPU(bus: ppuBus)
        oamDMA = OAMDMA(cpu: cpu)
        
        if !allRAM {
            let ppuRegisters = ppu.addressableRegisters
            let ppuMirror = Mirror(mirroring: ppuRegisters, times: 1023)
            mainBus.addDevice(ppuMirror, at: 0x2000)
            
            mainBus.addDevice(oamDMA, at: 0x4014)
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
        mainBus.write(0x00, at: 0xFFFC)
        mainBus.write(0x80, at: 0xFFFD)
    }
    
    func startup() {
        cpu.startup()
    }
    
    func reset() {
        cpu.reset()
    }
    
    func tick() {
        cpu.tick()
        oamDMA.tick()
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
