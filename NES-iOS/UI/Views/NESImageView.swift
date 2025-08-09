//
//  NESImageView.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-08.
//

import SwiftUI

struct NESImageView : View {
    var image: UIImage?
    
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(Color.black)
                    .aspectRatio(4.0 / 3.0, contentMode: .fit)
            }
        }
    }
}
