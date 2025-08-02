//
//  PPURegisters.h
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-01.
//

#ifndef PPURegisters_h
#define PPURegisters_h

#import <stdint.h>

// These bits all adapted from https://github.com/OneLoneCoder/olcNES/blob/master/Part%20%235%20-%20PPU%20Foregrounds/olc2C02.h

typedef union
{
    // https://www.nesdev.org/wiki/PPU_scrolling#PPU_internal_registers
    struct
    {

        uint16_t coarse_x : 5;
        uint16_t coarse_y : 5;
        uint16_t nametable_x : 1;
        uint16_t nametable_y : 1;
        uint16_t fine_y : 3;
        uint16_t unused : 1;
    };

    uint16_t reg;
} internal_ppu_address_register;

typedef union
{
    struct
    {
        uint8_t palette : 2;
        uint8_t unused : 3;
        uint8_t priority : 1;
        uint8_t flip_horizontally : 1;
        uint8_t flip_vertically : 1;
    };
    
    uint8_t reg;
} internal_oam_attributes;

typedef struct
{
    uint8_t y;
    uint8_t tile_index;
    internal_oam_attributes attributes;
    uint8_t x;
} internal_oam_entry;

#endif /* PPURegisters_h */
