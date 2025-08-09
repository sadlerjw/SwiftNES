//
//  Controller.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-08.
//

protocol Controller {
    func getPressedButtons() -> ControllerButton
}

struct ControllerButton : OptionSet {
    var rawValue: Byte
    
    static var a = ControllerButton(rawValue: 1 << 0)
    static var b = ControllerButton(rawValue: 1 << 1)
    static var select = ControllerButton(rawValue: 1 << 2)
    static var start = ControllerButton(rawValue: 1 << 3)
    static var up = ControllerButton(rawValue: 1 << 4)
    static var down = ControllerButton(rawValue: 1 << 5)
    static var left = ControllerButton(rawValue: 1 << 6)
    static var right = ControllerButton(rawValue: 1 << 7)
}

class Controllers : Addressable {
    var length: Int = 2
    var name: String { "Controllers" }
    
    var controller1: Controller?
    var controller2: Controller?
    
    private(set) var isLatchingControllerState = false
    private(set) var controller1State: Byte = 0
    private(set) var controller2State: Byte = 0
    
    func write(_ value: Byte, at offset: Offset) {
        if offset == 0 {
            isLatchingControllerState = (value & 0x01) != 0
        }
        if isLatchingControllerState {
            latchControllerState()
        }
    }
    
    private func latchControllerState() {
        controller1State = controller1?.getPressedButtons().rawValue ?? 0
        controller2State = controller2?.getPressedButtons().rawValue ?? 0
    }
    
    func read(at offset: Offset) -> Byte {
        guard offset < length else { return 0 }
        
        if isLatchingControllerState {
            latchControllerState()
        }
        
        switch offset {
        case 0:
            let state = controller1State
            controller1State = controller1State >> 1
            return state
        case 1:
            let state = controller1State
            controller1State = controller2State >> 1
            return state
        default:
            assertionFailure()
            return 0
        }
    }
    
    
}
