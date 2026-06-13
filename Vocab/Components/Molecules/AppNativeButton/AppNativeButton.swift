//
//  AppNativeButton.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI


struct AppGlassButton: View {
    
    var icon: String? = nil
    var text: String? = nil
    var action: () -> Void
    var isGlass: Bool = true
    var horizontalPadding: CGFloat = AppPadding.areaPadding 
    var verticalPadding: CGFloat = AppPadding.areaPadding
    
    var body: some View {
        Button(action: action) {

            HStack(spacing: 8) {

                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .semibold))
                }
                

                if let buttonText = text {
                    Text(buttonText)
                        .font(.system(size: 16, weight: .bold))
                }
                
            }
            .padding(.vertical , verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .foregroundColor(.primary)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
            .glassEffect()
        }
        .buttonStyle(.plain)
    }
}




#Preview {
    ZStack {

        Color.teal
            .ignoresSafeArea()
        
      
        VStack(spacing: 40) {
            

            
            AppGlassButton(
                text: "Selesai",
                action: { print("Done tapped") }
            )
            AppGlassButton(
                icon: "chevron.left",
                action: { print("Back tapped") }
            )
            
            AppGlassButton(
                icon: "square.and.arrow.down.fill",
                text: "Simpan Sketsa",
                action: { print("Save tapped") }
            )
            
        }
    }
}
