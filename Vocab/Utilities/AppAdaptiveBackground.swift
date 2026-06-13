//
//  AppAdaptiveBackground.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 13/06/26.
//

import SwiftUI

struct AdaptiveBackgroundModifier: ViewModifier {
    // Detect the current system color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Default colors are set here so it's ready to use out of the box
    var lightColor: Color = .white
    var darkColor: Color = Color(UIColor.secondarySystemBackground)
    
    func body(content: Content) -> some View {
        content
            // Apply color conditionally based on the active scheme
            .background(colorScheme == .dark ? darkColor : lightColor)
    }
}

// Extension to make it clean to use on any View
extension View {
    // Inject default values here as well for maximum flexibility
    func adaptiveBackground(
        lightColor: Color = .white,
        darkColor: Color = Color(UIColor.secondarySystemBackground)
    ) -> some View {
        self.modifier(AdaptiveBackgroundModifier(lightColor: lightColor, darkColor: darkColor))
    }
}
