//
//  MemoryBasedAddressingMode.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-07.
//

protocol MemoryBasedAddressingMode : AddressingMode, AnyObject {
    var computedAddress: AddressingModeComputedAddress? { get }
    var fetchedData: Byte? { get set }
    
    func computeAddress(cpu: borrowing CPU)
}

extension MemoryBasedAddressingMode {
    func fetch(cpu: borrowing CPU, addingCycleIfPageCrossed: Bool) -> Byte {
        guard let computedAddress else { fatalError("Reading via a memory-based address mode requires an address")}
        
        if addingCycleIfPageCrossed && computedAddress.crossedPageBoundary {
            cpu.cyclesBeforeNextInstruction += 1
        }
        
        let fetchedData = cpu.bus.read(computedAddress.address)
        self.fetchedData = fetchedData
        
        return fetchedData
    }
    
    func write(_ value: Byte, cpu: borrowing CPU) {
        guard let address = computedAddress?.address else { fatalError("Writing via a memory-based address mode requires an address")}
        cpu.bus.write(value, at: address)
    }
}
