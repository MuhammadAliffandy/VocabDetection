//
//  AppButtonModifier.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//
import SwiftUI


// modifier button style
struct AppPrimaryButtonStyle: ButtonStyle {
        
    var bgColor: Color = .blue

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, AppPadding.buttonPadding)
            .padding(.horizontal, AppPadding.buttonPadding)
            .frame(maxWidth: .infinity)
            .background(bgColor)
            .foregroundColor(.white)
            .cornerRadius(.infinity)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

//2. EXTENSION FOR CLEANER SYNTAX
extension ButtonStyle where Self == AppPrimaryButtonStyle {
    static var appPrimary: AppPrimaryButtonStyle {
        AppPrimaryButtonStyle()
    }
    
    static func appPrimary(color: Color) -> AppPrimaryButtonStyle {
            AppPrimaryButtonStyle(bgColor: color)
        }
}

