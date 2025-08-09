//
//  ControllerView.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-08.
//

import SwiftUI

@Observable
class ViewableController : Controller {
    private var pressedButtons: ControllerButton = []
    
    func set(button: ControllerButton, pressed: Bool) {
        if pressed {
            pressedButtons.insert(button)
        } else {
            pressedButtons.remove(button)
        }
    }
    
    func getPressedButtons() -> ControllerButton {
        return pressedButtons
    }
}

struct ControllerView: View {
    @GestureState private var touchLocation: CGPoint = .zero
    var viewableController: ViewableController
    
    var body: some View {
        HStack {
            DPadView()
            ControllerButtonView(text: "Select", touchLocation: touchLocation) { isTouching in
                viewableController.set(button: .select, pressed: isTouching)
            }
            ControllerButtonView(text: "Start", touchLocation: touchLocation){ isTouching in
                viewableController.set(button: .start, pressed: isTouching)
            }
            ControllerButtonView(text: "A", touchLocation: touchLocation){ isTouching in
                viewableController.set(button: .a, pressed: isTouching)
            }
            ControllerButtonView(text: "B", touchLocation: touchLocation){ isTouching in
                viewableController.set(button: .b, pressed: isTouching)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($touchLocation, body: { value, state, transaction in
                state = value.location
            }))
    }
}

struct DPadView: View {
    var body: some View {
        Text("DPad")
    }
}

struct ControllerButtonView: View {
    var text: any StringProtocol
    var touchLocation: CGPoint
    var onTouchChange: ((Bool) -> Void)?
    
    @State private var isTouchingInside: Bool = false
    
    var body: some View {
        Text(text)
            .frame(width: 64, height: 64)
            .background(isTouchingInside ? .pink : .purple)
            .background(GeometryReader { proxy in
                Rectangle()
                    .onChange(of: touchLocation) { oldValue, newValue in
                        isTouchingInside = proxy.frame(in: .global).contains(touchLocation)
                    }
            })
            .onChange(of: isTouchingInside) { oldValue, newValue in
                guard oldValue != newValue else { return }
                onTouchChange?(newValue)
            }
    }
}

#Preview {
    ControllerView(viewableController: .init())
}
