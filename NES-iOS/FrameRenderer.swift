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
    func image(from nesBuffer: Data) -> UIImage {
        assert(nesBuffer.count == 4 * 256 * 240)
        let size = CGSize(width: 256, height: 240)
        let ciImage = CIImage(bitmapData: nesBuffer,
                              bytesPerRow: 4 * 256,
                              size: size,
                              format: .RGBA8,
                              colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
        
        if let cgImage = CIContext().createCGImage(ciImage, from: .init(origin: .zero, size: size)) {
            return UIImage(cgImage: cgImage)
        } else {
            assertionFailure()
            return UIImage(ciImage: ciImage)
        }
    }
}
