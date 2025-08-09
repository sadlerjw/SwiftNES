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
    struct BreakpointEncounteredError: Error {
        var address: Address
    }
    
    struct MapperNotSupportedError : Error{
        var mapperNumber: Int
    }
    
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
    
    let mainBus: any BusProtocol
    let ppuBus: any BusProtocol
    
    let controllers: Controllers
    let vram: VRAM
    let paletteRAM: RAM_legacy
    
    let cpu : CPU
    let ppu : PPU
    let oamDMA : OAMDMA
    
    var breakpoints = Set<Address>()
    
    private(set) var clockCount : UInt = 0
    
    /// Sets up a full NES emulator stack. `startup()` should be called before use.
    /// - Parameter allRam: Set up a huge bank of RAM on the main bus instead of mapping devices.
    ///                         Should be used only for unit tests or debugging.
    init(allRAM: Bool = false, busType: any BusProtocol.Type = Bus.self) {
        mainBus = busType.init()
        ppuBus = busType.init()
        
        let controllers = Controllers()
        self.controllers = controllers
        
        let vram = VRAM()
        self.vram = vram
        
        let paletteRAM = RAM_legacy(length: 0x0020)
        self.paletteRAM = paletteRAM
        
        if allRAM {
            let ram: any Addressable = {
#if compiler(>=6.2)
                if #available(iOS 26.0, *) {
                    return RAM_26<0x10000>()
                } else {
                    return RAM_legacy(length: 0x10000)
                }
#else
                return RAM_legacy(length: 0x10000)
#endif
            }()
            mainBus.addDevice(ram, at: 0x0000)
            
            let ppuRAM: any Addressable = {
#if compiler(>=6.2)
                if #available(iOS 26.0, *) {
                    return RAM_26<0x4000>()
                } else {
                    return RAM_legacy(length: 0x4000)
                }
#else
                return RAM_legacy(length: 0x4000)
#endif
            }()
            ppuBus.addDevice(ppuRAM, at: 0x0000)
        } else {
            // MARK: CPU Bus
            let ram: any Addressable = {
#if compiler(>=6.2)
                if #available(iOS 26.0, *) {
                    return RAM_26<0x800>()
                } else {
                    return RAM_legacy(length: 0x800)
                }
#else
                return RAM_legacy(length: 0x800)
#endif
            }()
            let ramMirror = Mirror(mirroring: ram, times: 3)
            mainBus.addDevice(ramMirror, at: MainBusAddresses.ramStart)
            
            // PPU registers normally get mapped here, but first we have to
            // create the PPU! So it happens later.
            
            let apuRegisters: any Addressable = {
#if compiler(>=6.2)
                if #available(iOS 26.0, *) {
                    return RAM_26<0x14>()
                } else {
                    return RAM_legacy(length: 0x14)
                }
#else
                return RAM_legacy(length: 0x14)
#endif
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
                    controllers.write(value, at: 0)
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
                    return controllers.read(at: 0)
                case 2:
                    return controllers.read(at: 1)
                default:
                    fatalError("Received impossible offset \(offset) in Joystick/IRQ/FrameCounter addressable")
                }
            }
            
            mainBus.addDevice(joystickAndIRQAndAPUFrameCounter, at: MainBusAddresses.apuSoundStatus)
            
            // $4018–$401F are for CPU test mode, so unused for us.
            
            // The actual cartridge will handle these addresses but it's useful
            // to have a dummy on the bus so that tests and debugging code can
            // run even when no cartridge is loaded
            let cartridgeCPUMap = DummyAddressable(length: 0xBFE0)
            mainBus.addDevice(cartridgeCPUMap, at: MainBusAddresses.cartridgeStart)
            
            // MARK: PPU Bus
            let cartridgePPUMap = DummyAddressable(length: 0x2000)
            ppuBus.addDevice(cartridgePPUMap, at: PPUBusAddresses.cartridgeStart)
            
            let mirroredVRAM = ClosureAddressable(length: 0x0F00,
                                                  name: "Mirrored VRAM") { value, offset in
                vram.write(value, at: offset)
            } read: { offset in
                return vram.read(at: offset)
            }
            
            ppuBus.addDevice(vram, at: 0x2000)
            ppuBus.addDevice(mirroredVRAM, at: 0x3000)

            let paletteMirror = Mirror(mirroring: paletteRAM, times: 7)
            ppuBus.addDevice(paletteMirror, at: PPUBusAddresses.paletteRAMIndexesStart)
        }
        
        cpu = CPU(bus: mainBus)
        ppu = PPU(bus: ppuBus, cpu: cpu, paletteRAMDirectAccess: paletteRAM)
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
        ppu.startup()
    }
    
    func reset() {
        cpu.reset()
        ppu.reset()
    }
    
    func attachControllers(controller1: Controller?, controller2: Controller?) {
        controllers.controller1 = controller1
        controllers.controller2 = controller2
    }
    
    func loadCartridge(data: Data) throws {
        let rom = try INESFile(data: data)
        guard let mapperType = Mappers.mappers[Int(rom.header.mapperNumber)] else {
            throw MapperNotSupportedError(mapperNumber: Int(rom.header.mapperNumber))
        }
        
        let mapper = mapperType.init(iNESFile: rom)
        mainBus.cartridgeMapper = mapper.cpuAddressSpace
        ppuBus.cartridgeMapper = mapper.ppuAddressSpace
        
        vram.mirroring = rom.header.flags6.nametableMirroring
        
        reset()
    }
    
    func setPCForHeadlessTestROM() {
        cpu.pc = 0xC000
    }
    
    func tick(enableBreakpoints: Bool) throws {
        if clockCount % 3 == 0 {
            guard !(enableBreakpoints && breakpoints.contains(cpu.pc)) else {
                throw BreakpointEncounteredError(address: cpu.pc)
            }
            cpu.tick()
            oamDMA.tick()
            clockCount = 0
        }
        
        ppu.tick()
        clockCount += 1
    }
    
    func tickCPU(enableBreakpoints: Bool = false) throws {
        while clockCount % 3 != 0 {
            try tick(enableBreakpoints: enableBreakpoints)
        }
        try tick(enableBreakpoints: enableBreakpoints)
    }
    
    func stepCPU(enableBreakpoints: Bool = false) throws {
        if cpu.cyclesBeforeNextInstruction == 0 {
            try tickCPU(enableBreakpoints: enableBreakpoints)
        }
        while cpu.cyclesBeforeNextInstruction > 0 {
            try tickCPU(enableBreakpoints: enableBreakpoints)
        }
    }
    
    func stepFrame() throws {
        while ppu.status.contains(.vblank) {
            try tick(enableBreakpoints: true)
        }
        while !ppu.status.contains(.vblank) {
            try tick(enableBreakpoints: true)
        }
    }
}
