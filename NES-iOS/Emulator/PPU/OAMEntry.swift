//
//  OAMEntry.swift
//  NES-iOS
//
//  Created by Jason Sadler on 2025-08-01.
//

struct OAMEntry {
    struct Attributes {
        enum Priority : UInt8 {
            case foreground = 0
            case behindBackground = 1
        }
        
        var rawValue: internal_oam_attributes
        
        var palette: Byte { // Ranges from 4-7, stored as 0-3
            get { rawValue.palette + 4 }
            set { rawValue.palette = newValue - 4 }
        }
        
        var priority: Priority {
            get { Priority(rawValue: rawValue.priority)! }
            set { rawValue.priority = newValue.rawValue & 0x1 }
        }
        
        var flipHorizontally : Bool {
            get { return rawValue.flip_horizontally == 1 }
            set { rawValue.flip_horizontally = newValue ? 1 : 0 }
        }
        
        var flipVertically : Bool {
            get { return rawValue.flip_vertically == 1 }
            set { rawValue.flip_vertically = newValue ? 1 : 0 }
        }
    }
    
    var rawValue : internal_oam_entry
    
    var x : Byte {
        get { rawValue.x }
        set { rawValue.x = newValue }
    }
    
    var y : Byte {
        get { rawValue.y }
        set { rawValue.y = newValue }
    }
    
    var tileIndex : Byte {
        get { rawValue.tile_index }
        set { rawValue.tile_index = newValue }
    }
    
    var attributes : Attributes {
        get { .init(rawValue: rawValue.attributes) }
        set { rawValue.attributes = newValue.rawValue }
    }
}
