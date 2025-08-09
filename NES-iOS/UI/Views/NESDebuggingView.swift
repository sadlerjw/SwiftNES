//
//  NESDebuggingView.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-29.
//

import SwiftUI

struct NESDebuggingView: View {
    var nes : NES

    @State var isAddingBreakpoint = false
    @State var newBreakpointAddress = ""
    @State var nesState = OnDemandNESState()
    
    var renderer: FrameRenderer
    
    @ViewBuilder
    var cpuSection: some View {
        VStack {
            HStack {
                CPUStatusView("C", isEnabled: nesState.cpu.status.contains(.c))
                CPUStatusView("Z", isEnabled: nesState.cpu.status.contains(.z))
                CPUStatusView("I", isEnabled: nesState.cpu.status.contains(.i))
                CPUStatusView("D", isEnabled: nesState.cpu.status.contains(.d))
                CPUStatusView("B", isEnabled: nesState.cpu.status.contains(.b))
                CPUStatusView("?", isEnabled: nesState.cpu.status.contains(.one_unused))
                CPUStatusView("O", isEnabled: nesState.cpu.status.contains(.o))
                CPUStatusView("N", isEnabled: nesState.cpu.status.contains(.n))
            }
            .redacted(reason: renderer.isPaused ? [] : .placeholder)
            
            Grid(horizontalSpacing: 48) {
                GridRow {
                    ValueRedactableLabeledContent("A", value: nesState.cpu.a.hexCode)
                    ValueRedactableLabeledContent("X", value: nesState.cpu.x.hexCode)
                    ValueRedactableLabeledContent("Y", value: nesState.cpu.y.hexCode)
                }
                GridRow {
                    ValueRedactableLabeledContent("PC", value: nesState.cpu.pc.hexCode)
                    ValueRedactableLabeledContent("SP", value: nesState.cpu.stackPointer.hexCode)
                    ValueRedactableLabeledContent("Top", value: "\(nesState.cpu.topOfStackNext.hexCode) \(nesState.cpu.topOfStack.hexCode)")
                }
            }
            .redacted(reason: renderer.isPaused ? [] : .placeholder)
        }
        .padding()
        .backgroundStyle(.background)
        .background(in: ButtonBorderShape.roundedRectangle)
        .padding()
    }
    
    @ViewBuilder
    var ramSection: some View {
        Section("RAM") {
            ForEach(nesState.addressSpaceSliceContainingPC) { tuple in
                let address = Address(tuple.index)
                let value = tuple.element
                
                let isNextInstruction = renderer.isPaused && address == nesState.cpu.pc
                let backgroundStyle = isNextInstruction ? AnyShapeStyle(Color.green) : AnyShapeStyle(.background)
                
                HStack(alignment: .center) {
                    if nesState.breakpoints.contains(address) {
                        Circle().frame(width: 8, height: 8).foregroundColor(.blue)
                    }
                    ValueRedactableLabeledContent(address.hexCode,
                                                  value: "\(value.hexCode) | \(OpcodeReference.lookupTable[value]?.instruction.name ?? "Invalid")")
                }
                .listRowBackground(Rectangle().foregroundStyle(backgroundStyle))
                .contextMenu {
                    Button {
                        if nes.breakpoints.contains(address) {
                            nes.breakpoints.remove(address)
                        } else {
                            nes.breakpoints.insert(address)
                        }
                        nesState.update(from: nes)
                    } label: {
                        Label("Toggle Breakpoint", systemImage: "arrow.forward.to.line.square")
                    }

                }
            }
            .redacted(reason: renderer.isPaused ? [] : .placeholder)
        }
    }

    var body: some View {
        VStack {
            cpuSection
            ScrollViewReader { proxy in
                List {
                    ramSection
                }.onChange(of: nesState.cpu.pc) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(Int(newValue))
                    }
                }
            }
        }
        .background(Color(uiColor: UIColor.systemGroupedBackground))
        .task {
            nesState = .init(nes: nes)
        }
        .alert("Add Breakpoint", isPresented: $isAddingBreakpoint, actions: {
            TextField("Address", text: $newBreakpointAddress)
            Button("Add") {
                isAddingBreakpoint = false
                if let address = UInt16(newBreakpointAddress, radix: 16) {
                    nes.breakpoints.insert(address)
                    nesState.update(from: nes)
                }
                newBreakpointAddress = ""
            }
            Button("Cancel", role: .cancel) {
                isAddingBreakpoint = false
                newBreakpointAddress = ""
            }
        })
        .onChange(of: renderer.isPaused, { oldValue, newValue in
            if !oldValue && newValue {
                nesState.update(from: nes)
            }
        })
        .navigationTitle("Debugger")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    renderer.isPaused = true
                    nes.reset()
                    nesState.update(from: nes)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if renderer.isPaused {
                    Button("Resume", systemImage: "play") {
                        renderer.isPaused = false
                        nesState.update(from: nes)
                    }
                } else {
                    Button("Pause", systemImage: "pause") {
                        renderer.isPaused = true
                        nesState.update(from: nes)
                    }
                }

            }
            ToolbarItem(placement: .bottomBar) {
                Button("Step", systemImage: "arrow.forward") {
                    renderer.isPaused = true
                    try? nes.stepCPU(enableBreakpoints: false)
                    nesState.update(from: nes)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Step to next frame", systemImage: "arrow.forward.to.line") {
                    renderer.isPaused = true
                    try? nes.stepFrame()
                    renderer.renderCurrentFrame()
                    nesState.update(from: nes)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Add Breakpoint", systemImage: "arrow.forward.to.line.square") {
                    isAddingBreakpoint = true
                }
            }
        }
    }
}

struct CPUStatusView : View {
    var label: any StringProtocol
    var isEnabled: Bool
    
    @Environment(\.redactionReasons) var redactionReasons
    
    init(_ label: any StringProtocol, isEnabled: Bool) {
        self.label = label
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        let foregroundStyle : Color = {
            if redactionReasons.isEmpty {
                return isEnabled ? .green : .red
            } else {
                return .secondary
            }
        }()
        
        Text(label).foregroundStyle(foregroundStyle)
            .unredacted()
    }
}



#Preview {
    NESDebuggingView(nes: NES(), renderer: FrameRenderer())
}
