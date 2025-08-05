//
//  ValueRedactableLabeledContent.swift
//  SwiftNES
//
//  Created by Jason Sadler on 2025-08-05.
//

import SwiftUI

struct ValueRedactableLabeledContent : View {
    var titleView: Text
    var value: any StringProtocol
    
    @Environment(\.redactionReasons) var redactionReasons
    
    init(_ titleKey: LocalizedStringKey, value: any StringProtocol) {
        self.titleView = Text(titleKey)
        self.value = value
    }
    
    init(_ title: any StringProtocol, value: any StringProtocol) {
        self.titleView = Text(title)
        self.value = value
    }
    
    var body: some View {
        LabeledContent {
            Text(value)
                .redacted(reason: redactionReasons)
        } label: {
            titleView
        }.unredacted()
    }
}
