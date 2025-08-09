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
    var controller: ViewableController
    
    var body: some View {
        HStack {
            DPadView(touchLocation: touchLocation, controller: controller)
            ControllerButtonView(text: "Select", touchLocation: touchLocation) { isTouching in
                controller.set(button: .select, pressed: isTouching)
            }
            ControllerButtonView(text: "Start", touchLocation: touchLocation){ isTouching in
                controller.set(button: .start, pressed: isTouching)
            }
            ControllerButtonView(text: "A", touchLocation: touchLocation){ isTouching in
                controller.set(button: .a, pressed: isTouching)
            }
            ControllerButtonView(text: "B", touchLocation: touchLocation){ isTouching in
                controller.set(button: .b, pressed: isTouching)
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
    var touchLocation: CGPoint
    var controller: ViewableController
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                ControllerButtonView(text: "UL", touchLocation: touchLocation) { isTouching in
                    controller.set(button: [.up, .left], pressed: isTouching)
                }
                ControllerButtonView(text: "U", touchLocation: touchLocation) { isTouching in
                    controller.set(button: .up, pressed: isTouching)
                }
                ControllerButtonView(text: "UR", touchLocation: touchLocation) { isTouching in
                    controller.set(button: [.up, .right], pressed: isTouching)
                }
            }
            GridRow {
                ControllerButtonView(text: "L", touchLocation: touchLocation) { isTouching in
                    controller.set(button: .left, pressed: isTouching)
                }
                Rectangle()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.clear)
                ControllerButtonView(text: "R", touchLocation: touchLocation) { isTouching in
                    controller.set(button: .right, pressed: isTouching)
                }
            }
            GridRow {
                ControllerButtonView(text: "DL", touchLocation: touchLocation) { isTouching in
                    controller.set(button: [.down, .left], pressed: isTouching)
                }
                ControllerButtonView(text: "D", touchLocation: touchLocation) { isTouching in
                    controller.set(button: .down, pressed: isTouching)
                }
                ControllerButtonView(text: "DR", touchLocation: touchLocation) { isTouching in
                    controller.set(button: [.down, .right], pressed: isTouching)
                }
            }
        }
    }
}

struct ControllerButtonView: View {
    var text: any StringProtocol
    var touchLocation: CGPoint
    var onTouchChange: ((Bool) -> Void)?
    
    @State private var isTouchingInside: Bool = false
    
    var body: some View {
        Text(text)
            .frame(width: 48, height: 48)
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
    ControllerView(controller: .init())
}
