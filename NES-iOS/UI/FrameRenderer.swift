//
//  FrameRenderer.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-04.
//

import Foundation
import CoreImage
import Observation
import UIKit

@Observable
class FrameRenderer {
    private let context = CIContext()
    private var nes : NES! = nil
    var image: UIImage? = nil
    var isPaused = true
    var fps : Int {
        let sum = frameDurations.reduce(0, +)
        guard sum > 0 else { return 0}
        
        return Int(Double(frameDurations.count) / sum)
    }
    
    private var frameIndex = 0
    private var frameDurations = [CFTimeInterval](repeating: 0, count: 5)
    private var lastFrameTimestamp : CFTimeInterval = 0
    
    func start(with nes: NES) {
        self.nes = nes
        
        let displayLink = CADisplayLink(target: self, selector: #selector(renderFrame(displayLink:)))
        displayLink.preferredFrameRateRange = .init(minimum: 60, maximum: 60, preferred: 60)
        displayLink.add(to: .main, forMode: .default)
    }
    
    @objc private func renderFrame(displayLink: CADisplayLink) {
        guard !isPaused,
              let nes else { return }
        
        frameDurations[frameIndex] = displayLink.timestamp - lastFrameTimestamp
        frameIndex = (frameIndex + 1) % frameDurations.count
        
        lastFrameTimestamp = displayLink.timestamp
        
        nes.stepFrame()
        image = image(from: nes.ppu.previousFrame)
    }
    
    func image(from nesBuffer: Data) -> UIImage {
        assert(nesBuffer.count == 4 * 256 * 240)
        let size = CGSize(width: 256, height: 240)
        let ciImage = CIImage(bitmapData: nesBuffer,
                              bytesPerRow: 4 * 256,
                              size: size,
                              format: .RGBA8,
                              colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
        
        if let cgImage = context.createCGImage(ciImage, from: .init(origin: .zero, size: size)) {
            return UIImage(cgImage: cgImage)
        } else {
            assertionFailure()
            return UIImage(ciImage: ciImage)
        }
    }
}
