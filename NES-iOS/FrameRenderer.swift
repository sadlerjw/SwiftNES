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
    var fps : Int { frameCount == 0 ? 0 : Int(totalFrameDurations / Double(frameCount)) }
    
    private var frameCount = 0
    private var totalFrameDurations : CFTimeInterval = 0
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
        
        let actualFramesPerSecond = 1 / (displayLink.timestamp - lastFrameTimestamp)
        totalFrameDurations += actualFramesPerSecond
        frameCount += 1
        
//        print("Frame time: \(displayLink.timestamp - lastFrameTimestamp)")
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
