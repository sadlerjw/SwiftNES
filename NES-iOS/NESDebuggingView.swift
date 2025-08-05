//
//  NESDebuggingView.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-29.
//

import SwiftUI

struct NESDebuggingView: View {
    @Environment(NES.self) var nes : NES
    @State var image: UIImage?
    @State var renderer = FrameRenderer()

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Rectangle()
                .fill(Color.black)
                .aspectRatio(4.0 / 3.0, contentMode: .fit)
        }
        List {
            Section("CPU") {
                HStack {
                    Text("C").foregroundStyle(nes.cpu.status.contains(.c) ? .green : .red)
                    Text("Z").foregroundStyle(nes.cpu.status.contains(.z) ? .green : .red)
                    Text("I").foregroundStyle(nes.cpu.status.contains(.i) ? .green : .red)
                    Text("D").foregroundStyle(nes.cpu.status.contains(.d) ? .green : .red)
                    Text("B").foregroundStyle(nes.cpu.status.contains(.b) ? .green : .red)
                    Text("?").foregroundStyle(nes.cpu.status.contains(.one_unused) ? .green : .red)
                    Text("O").foregroundStyle(nes.cpu.status.contains(.o) ? .green : .red)
                    Text("N").foregroundStyle(nes.cpu.status.contains(.n) ? .green : .red)
                }
                ViewThatFits {
                    HStack(spacing: 32) {
                        LabeledContent("A", value: nes.cpu.a.hexCode)
                        LabeledContent("X", value: nes.cpu.x.hexCode)
                        LabeledContent("Y", value: nes.cpu.y.hexCode)
                        LabeledContent("PC", value: nes.cpu.pc.hexCode)
                        LabeledContent("SP", value: nes.cpu.stack.stackPointer.hexCode)
                    }
                    Grid(horizontalSpacing: 48) {
                        GridRow {
                            LabeledContent("A", value: nes.cpu.a.hexCode)
                            LabeledContent("X", value: nes.cpu.x.hexCode)
                            LabeledContent("Y", value: nes.cpu.y.hexCode)
                        }
                        GridRow {
                            LabeledContent("PC", value: nes.cpu.pc.hexCode)
                            LabeledContent("SP", value: nes.cpu.stack.stackPointer.hexCode)
                        }
                    }
                }
            }

            Section("RAM") {
                ForEach(0x8000 ..< 0x8010) { address in
                    let value = nes.mainBus.read(UInt16(address))
                    let isNextInstruction = address == nes.cpu.pc
                    let backgroundStyle = isNextInstruction ? AnyShapeStyle(Color.green) : AnyShapeStyle(.background)
                    LabeledContent(String(format: " %04X", address), value: "\(String(format: " %04X", value)) | \(OpcodeReference.lookupTable[value]?.instruction.name ?? "Invalid")")
                        .listRowBackground(Rectangle().foregroundStyle(backgroundStyle))
                }
            }
        }
        .navigationTitle("NES Emulator")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    nes.reset()
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Step", systemImage: "arrow.forward") {
                    nes.stepCPU()
                    image = renderer.image(from: nes.ppu.currentFrameBuffer)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Step to next frame", systemImage: "arrow.forward.to.line") {
                    nes.stepFrame()
                    image = renderer.image(from: nes.ppu.previousFrame)
                }
            }
        }
    }
}

#Preview {
    NESDebuggingView()
        .environment(NES())
}
