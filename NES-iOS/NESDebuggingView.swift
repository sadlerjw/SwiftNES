//
//  NESDebuggingView.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-29.
//

import SwiftUI

struct NESDebuggingView: View {
    var nes : NES
    @State var image: UIImage?
    @State var renderer = FrameRenderer()
    @State var nesState = OnDemandNESState()
    @State var visibleAddressSpaceRange: Range<Int> = 0x8000 ..< 0x8010

    var body: some View {
        VStack {
            if renderer.isPaused, let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let image = renderer.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(Color.black)
                    .aspectRatio(4.0 / 3.0, contentMode: .fit)
            }
            if !renderer.isPaused {
                LabeledContent("FPS", value: "\(renderer.fps)")
                    .frame(idealWidth: 70)
            }
            List {
                Section("CPU") {
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
                    
                    ViewThatFits {
                        HStack(spacing: 32) {
                            RedactableLabeledContent("A", value: nesState.cpu.a.hexCode)
                            RedactableLabeledContent("X", value: nesState.cpu.x.hexCode)
                            RedactableLabeledContent("Y", value: nesState.cpu.y.hexCode)
                            RedactableLabeledContent("PC", value: nesState.cpu.pc.hexCode)
                            RedactableLabeledContent("SP", value: nesState.cpu.stackPointer.hexCode)
                        }
                        Grid(horizontalSpacing: 48) {
                            GridRow {
                                RedactableLabeledContent("A", value: nesState.cpu.a.hexCode)
                                RedactableLabeledContent("X", value: nesState.cpu.x.hexCode)
                                RedactableLabeledContent("Y", value: nesState.cpu.y.hexCode)
                            }
                            GridRow {
                                RedactableLabeledContent("PC", value: nesState.cpu.pc.hexCode)
                                RedactableLabeledContent("SP", value: nesState.cpu.stackPointer.hexCode)
                            }
                        }
                    }
                    .redacted(reason: renderer.isPaused ? [] : .placeholder)
                }
                
                Section("RAM") {
                    ForEach(nesState.identifiableAddressSpaceSlice(visibleAddressSpaceRange)) { tuple in
                        let address = tuple.index
                        let value = tuple.element

                        let isNextInstruction = address == nesState.cpu.pc
                        let backgroundStyle = isNextInstruction ? AnyShapeStyle(Color.green) : AnyShapeStyle(.background)
                        LabeledContent(address.hexCode,
                                       value: "\(value.hexCode) | \(OpcodeReference.lookupTable[value]?.instruction.name ?? "Invalid")")
                            .listRowBackground(Rectangle().foregroundStyle(backgroundStyle))
                    }
                    .redacted(reason: renderer.isPaused ? [] : .placeholder)
                }
            }
        }
        .task {
            renderer.start(with: nes)
            nesState = .init(nes: nes)
        }
        .navigationTitle("NES Emulator")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    renderer.isPaused = true
                    nes.reset()
                    nesState.update(from: nes, includingAddressSpaceRange: visibleAddressSpaceRange)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if renderer.isPaused {
                    Button("Resume", systemImage: "play") {
                        renderer.isPaused = false
                        nesState.update(from: nes, includingAddressSpaceRange: visibleAddressSpaceRange)
                    }
                } else {
                    Button("Pause", systemImage: "pause") {
                        renderer.isPaused = true
                        if let image = renderer.image {
                            self.image = image
                        }
                        nesState.update(from: nes, includingAddressSpaceRange: visibleAddressSpaceRange)
                    }
                }

            }
            ToolbarItem(placement: .bottomBar) {
                Button("Step", systemImage: "arrow.forward") {
                    renderer.isPaused = true
                    nes.stepCPU()
                    nesState.update(from: nes, includingAddressSpaceRange: visibleAddressSpaceRange)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Step to next frame", systemImage: "arrow.forward.to.line") {
                    renderer.isPaused = true
                    nes.stepFrame()
                    image = renderer.image(from: nes.ppu.previousFrame)
                    nesState.update(from: nes, includingAddressSpaceRange: visibleAddressSpaceRange)
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

struct RedactableLabeledContent : View {
    var titleKey: LocalizedStringKey
    var value: any StringProtocol
    
    @Environment(\.redactionReasons) var redactionReasons
    
    init(_ titleKey: LocalizedStringKey, value: any StringProtocol) {
        self.titleKey = titleKey
        self.value = value
    }
    
    var body: some View {
        LabeledContent(titleKey) {
            Text(value)
                .redacted(reason: redactionReasons)
        }.unredacted()
    }
}

#Preview {
    NESDebuggingView(nes: NES())
}
