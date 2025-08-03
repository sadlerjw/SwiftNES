//
//  OAMDMA.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-03.
//

class OAMDMA : Addressable {
    enum CycleType {
        case read
        case write
        
        mutating func toggle() {
            switch self {
            case .read:
                self = .write
            case .write:
                self = .read
            }
        }
    }
    
    enum ActiveState {
        case inactive
        case pendingCPUHaltAndReadCycle
        case active
    }
    
    let length = 1
    let name = "OAM DMA"
    
    unowned let cpu: CPU
    private(set) var pageSourceAddress: Address = 0
    private(set) var bytesCopied: UInt8 = 0
    private(set) var cycleType = CycleType.read
    private(set) var currentValue: Byte = 0
    private(set) var activeState : ActiveState = .inactive
    
    init(cpu: CPU) {
        self.cpu = cpu
    }
    
    func tick() {
        defer { cycleType.toggle() }
        
        switch activeState {
        case .inactive:
            return
        case .pendingCPUHaltAndReadCycle:
            guard cpu.isHalted else {
                cpu.requestHalt()
                return
            }
            
            guard cpu.isHalted && cycleType == .read else {
                return
            }
            
            activeState = .active
        case .active:
            break
        }

        switch cycleType {
        case .read:
            currentValue = cpu.bus.read(pageSourceAddress + Address(bytesCopied))
        case .write:
            cpu.bus.write(currentValue, at: 0x2007)
            bytesCopied += 1
            
            if bytesCopied == 255 {
                bytesCopied = 0
                activeState = .inactive
                cpu.unHalt()
            }
        }
    }
    
    func write(_ value: Byte, at offset: Offset) {
        guard offset == 0 else {
            fatalError("OAM DMA received write on non-zero offset: \(offset)")
        }
        
        guard activeState == .inactive && bytesCopied == 0 else {
            fatalError("Shouldn't be possible to start OAM DMA while it one is still in progress")
        }
        
        pageSourceAddress = Address(value << 8)
        activeState = .pendingCPUHaltAndReadCycle   // Start trying to halt the CPU on the next cycle
    }
    
    func read(at offset: Offset) -> Byte {
        guard offset == 0 else {
            fatalError("OAM DMA received read on non-zero offset: \(offset)")
        }
        
        return 0
    }
}
