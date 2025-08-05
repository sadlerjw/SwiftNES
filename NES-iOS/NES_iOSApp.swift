//
//  NES_iOSApp.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-07-29.
//

import SwiftUI

@main
struct NES_iOSApp: App {
    @State var nes : NES = {
        let nes = NES()
//        nes.addDebugProgramToRam()
        nes.startup()
        return nes
    }()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                NESDebuggingView()
                    .environment(nes)
            }
        }
    }
}
