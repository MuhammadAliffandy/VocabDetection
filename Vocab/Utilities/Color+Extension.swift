//
//  Color+Extension.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

extension Color{
    init(hex: String) {

            let cleanedHex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            
            var rgb: UInt64 = 0
            Scanner(string: cleanedHex).scanHexInt64(&rgb)
            
            let red = Double((rgb >> 16) & 0xFF) / 255.0
            let green = Double((rgb >> 8) & 0xFF) / 255.0
            let blue = Double(rgb & 0xFF) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
        }
    
    
    static let brandColorPrimaryTeal = Color(hex: "#18AEBF")
    static let surfaceOnboardingColorPrimaryCream = Color(hex: "#FFF0E4")
    static let surfacePrimaryLightgrey = Color(hex: "#FAFAFA")
    static let textColorPrimarySemiBlack = Color(hex: "#000000")
    static let textColorSecondaryBlackGrey = Color(hex: "#7B7B7B")
    static let colorRedWarning = Color(hex: "#FF3B30")
    
}
