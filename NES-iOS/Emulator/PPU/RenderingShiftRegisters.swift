//
//  RenderingShiftRegisters.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-05.
//

extension PPU {
    struct RenderingShiftRegisters {
        private(set) var patternHigh : UInt16 = 0
        private(set) var patternLow : UInt16 = 0
        
        private(set) var attributesHigh : UInt16 = 0
        private(set) var attributesLow : UInt16 = 0
        
        mutating func loadPattern(high: Byte, low: Byte) {
            patternHigh = patternHigh & 0xFF00 | UInt16(high)
            patternLow = patternLow & 0xFF00 | UInt16(low)
        }
        
        mutating func loadAttributes(high: Bool, low: Bool) {
            attributesHigh = attributesHigh & 0xFF00 | (high ? 0x00FF : 0)
            attributesLow = attributesLow & 0xFF00 | (low ? 0x00FF : 0)
        }
        
        func pattern(fineX: UInt8) -> UInt8 {
            return select(fineX: fineX, fromHigh: patternHigh, low: patternLow)
        }
        
        func palette(fineX: UInt8) -> UInt8 {
            return select(fineX: fineX, fromHigh: attributesHigh, low: attributesLow)
        }
        
        private func select(fineX: UInt8, fromHigh high: UInt16, low: UInt16) -> Byte {
            guard fineX < 8 else {
                fatalError("FineX should never be greater than 7.")
            }
            let selector : UInt16 = 1 << (fineX + 8)
            
            let highResult : UInt8 = (high & selector) > 0 ? 1 : 0
            let lowResult : UInt8 = (low & selector) > 0 ? 1 : 0
            
            return highResult << 1 | lowResult
        }
        
        mutating func shift() {
            patternHigh = (patternHigh << 1) | 0x0001
            patternLow = (patternLow << 1) | 0x0001
            attributesHigh = (attributesHigh << 1) | 0x0001
            attributesLow = (attributesLow << 1) | 0x0001
        }
    }
}
