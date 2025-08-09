//
//  NESPlayerView.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-08.
//

import SwiftUI

struct NESPlayerView: View {
    var nes : NES
    
    @State var renderer = FrameRenderer()
    @State var isSelectingROM = false
    @State var isShowingDebugger = false
    @State var controller1 = ViewableController()
    
    var body: some View {
        VStack {
            NESImageView(image: renderer.image)
            if !renderer.isPaused {
                LabeledContent("FPS", value: "\(renderer.fps)")
                    .frame(idealWidth: 70)
            }
            ControllerView(controller: controller1)
                .background(.gray)
        }
        .task {
            renderer.start(with: nes)
            nes.attachControllers(controller1: controller1, controller2: nil)
        }
        .onChange(of: isSelectingROM, { oldValue, newValue in
            renderer.isPaused = newValue
        })
        .onChange(of: isShowingDebugger, { oldValue, newValue in
            renderer.isPaused = newValue
        })
        .popover(isPresented: $isSelectingROM, content: {
            RomSelector(nes: nes)
        })
        .popover(isPresented: $isShowingDebugger, content: {
            NESDebuggingView(nes: nes, renderer: renderer)
        })
        .navigationTitle("SwiftNES")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Load ROM", systemImage: "arrow.down.square.fill") {
                    renderer.isPaused = true
                    isSelectingROM = true
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Open Debugger", systemImage: "ant.circle") {
                    renderer.isPaused = true
                    isShowingDebugger = true
                }
            }
        }
    }
}

#Preview {
    NESPlayerView(nes: NES())
}
