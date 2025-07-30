//
//  IndirectX.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-07-30.
//

extension AddressingModes {
    struct Indirect : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let addressOfPointer = readAbsoluteBaseAddress(cpu: cpu)
            let pointerAddressLow = cpu.bus.read(addressOfPointer)
            let pointerAddressHigh = cpu.bus.read(addressOfPointer + 1)
            let pointerAddress = Address(low: pointerAddressLow, high: pointerAddressHigh)
            
            cpu.fetchedData = cpu.bus.read(pointerAddress)
        }
    }
    
    // (Indirect, X) - the byte after the opcode references a base
    // address within the zero page. We add the value of register X
    // to get the address of the low byte of a 2-byte pointer. The
    // next memory location in page zero is the high byte of the
    // ponter. Both must be within the zero page so we wrap addresses
    // to the beginning of the zero page during the addition.
    // Now we have the pointer and we load the value at _that_ address.
    //
    // Long story short, we access a table of pointers which starts
    // at the zero page address, and then index within that table
    // using X, and follow that pointer.
    struct IndirectX : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let zeroPageBaseAddress = cpu.bus.read(cpu.pc)
            let zeroPageAddress = zeroPageBaseAddress &+ cpu.x
            
            let pointerAddressLow = cpu.bus.read(Address(zeroPageAddress))
            let pointerAddressHigh = cpu.bus.read(Address(zeroPageAddress &+ 1))
            let pointerAddress = Address(low: pointerAddressLow, high: pointerAddressHigh)
            
            cpu.fetchedData = cpu.bus.read(pointerAddress)
        }
    }
    
    // (Indirect), Y - the byte after the opcode references a base
    // address within the zero page. We get the value at that address and
    // add the value of register Y to get the address of the low byte of
    // a 2-byte pointer. The carry from this addition is added to the value
    // of the next zero page location to form the high byte of the pointer.
    // Now we have the pointer and we load the value at _that_ address.
    //
    // Long story short, we follow a pointer in the zero page to a table
    // of values, and index within the table of values using Y.
    struct IndirectY : AddressingMode {
        static let sharedInstance = Self.init()
        
        func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) {
            let zeroPageAddress = cpu.bus.read(cpu.pc)
            
            let pointerBaseAddressLow = cpu.bus.read(Address(zeroPageAddress))
            let pointerBaseAddressHigh = cpu.bus.read(Address(zeroPageAddress &+ 1))
            let pointerBaseAddress = Address(low: pointerBaseAddressLow, high: pointerBaseAddressHigh)
            
            let pointerAddress = pointerBaseAddress + Address(cpu.y)
            
            cpu.fetchedData = cpu.bus.read(pointerAddress)
            
            if addingCycleIfPageCrossed &&
                pointerAddress.isOnDifferentPage(from: pointerBaseAddress) {
                cpu.cyclesBeforeNextInstruction += 1
            }
        }
    }
}

fileprivate func readAbsoluteBaseAddress(cpu: borrowing CPU) -> Address {
    let lowWord = cpu.bus.read(cpu.pc)
    cpu.pc += 1
    
    let highWord = cpu.bus.read(cpu.pc)
    
    let address = UInt16(highWord) << 8 | UInt16(lowWord)
    
    return address
}
