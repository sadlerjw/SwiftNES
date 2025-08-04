//
//  OAMDMATests.swift
//  NES-iOSTests
//
//  Created by Jason Sadler on 2025-08-04.
//

import Testing
@testable import NES_iOS

@MainActor
struct OAMDMATests {
    let nes = NES(allRAM: false)
    
    func setCycleType(_ cycleType: OAMDMA.CycleType) {
        while nes.oamDMA.cycleType != cycleType {
            nes.oamDMA.tick()
        }
    }

    @Test(arguments: [true, false]) func test(withAlignmentCycle: Bool) {
        // Make sure program counter starts at 0x0000, which will just spin
        nes.mainBus.write(0x00, at: NES.MainBusAddresses.resetVector)
        nes.mainBus.write(0x00, at: NES.MainBusAddresses.resetVector + 1)
        
        nes.startup()
        
        let pageOfData : [Byte] = {
            var data = [Byte]()
            for _ in 0..<256 {
                data.append(contentsOf: [UInt8.random(in: 0..<255)])
            }
            return data
        }()
        let startOfPage : Byte = 0x0A

        for (index, byte) in pageOfData.enumerated() {
            nes.mainBus.write(byte, at: Address(startOfPage) << 8 + Address(index))
        }
        
        setCycleType(withAlignmentCycle ? .read : .write) // On first tick, this will toggle to the value used in the first DMA tick.
                                                          // Which means we set .read to start DMA on a write cycle, forcuing an alignment cycle.
        
        nes.mainBus.write(0x00, at: NES.MainBusAddresses.OAMADDR)         // Clear OAMADDR
        nes.mainBus.write(startOfPage, at: NES.MainBusAddresses.OAMDMA)  // Start DMA
        
        var numberOfCyclesForHalt: Int = 0
        var numberOfCyclesForData: Int = 0
        
        while !nes.cpu.isHalted {
            numberOfCyclesForHalt += 1
            nes.cpu.tick()
            nes.oamDMA.tick()
            if numberOfCyclesForHalt > 20 {
                break   // Then something's wrong...but don't hang the test!
            }
        }

        while nes.cpu.isHalted {
            numberOfCyclesForData += 1
            nes.cpu.tick()
            nes.oamDMA.tick()
            if numberOfCyclesForData > 1000 {
                break   // Then something's wrong...but don't hang the test!
            }
        }
        
        for (index, byte) in pageOfData.enumerated() {
            #expect(nes.ppu.oam.raw.read(at: Address(index)) == byte)
        }
        #expect(numberOfCyclesForHalt == 1)
        #expect(numberOfCyclesForData == 512 + (withAlignmentCycle ? 1 : 0))
    }

}
