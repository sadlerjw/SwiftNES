//
//  NESDebuggingView.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-29.
//

import SwiftUI

struct NESDebuggingView: View {
    var nes : NES
    
    @ViewBuilder
    var ramSection: some View {
        Section("RAM") {
            ForEach(0x8000 ..< 0x8010) { address in
                let value = nes.ram.read(at: UInt16(address))
                let isNextInstruction = address == nes.cpu.pc
                let backgroundStyle = isNextInstruction ? AnyShapeStyle(Color.green) : AnyShapeStyle(.background)
                LabeledContent(String(format: " %04X", address), value: "\(String(format: " %04X", value)) | \(OpcodeReference.lookupTable[value]?.instruction.name ?? "Invalid")")
                    .listRowBackground(Rectangle().foregroundStyle(backgroundStyle))
            }
        }
    }
    
    var body: some View {
        List {
            Section("Status") {
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
            }
            Section("Registers") {
                LabeledContent("A", value: String(format: "%02X", nes.cpu.a))
                LabeledContent("X", value: String(format: "%02X", nes.cpu.x))
                LabeledContent("Y", value: String(format: "%02X", nes.cpu.y))
                LabeledContent("PC", value: String(format: "%04X", nes.cpu.pc))
                LabeledContent("SP", value: String(format: "%02X", nes.cpu.stack.stackPointer))
            }
            ramSection
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
                }
            }
        }
    }
}

#Preview {
    NESDebuggingView(nes: NES())
}
