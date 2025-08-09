//
//  RomSelector.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-06.
//

import SwiftUI

struct RomSelector: View {
    struct ROM : Identifiable {
        var url: URL
        var id: URL { url }
    }

    var nes: NES
    
    @State var roms: [ROM] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List(roms) { rom in
            Button(rom.url.lastPathComponent) {
                do {
                    try nes.loadCartridge(data: Data(contentsOf: rom.url))
//                    if rom.url.lastPathComponent == "nestest.nes" {
//                        nes.setPCForHeadlessTestROM()
//                    }
                    dismiss()
                } catch {
                    // TODO: error handling
                    print(error)
                }
            }
        }
        .task {
            let testRomURL = Bundle.main.url(forResource: "nestest", withExtension: "nes")!
            let directory = testRomURL.deletingLastPathComponent()
            let urls = try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            roms = urls.filter { $0.pathExtension == "nes" }
                .map(ROM.init)
        }.navigationTitle("ROMs")
    }
}

#Preview {
    RomSelector(nes: NES())
}
