//
//  FlashcardCTABanner.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct FlashcardCTABanner: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Uji Ingatanmu!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Mainkan flashcard sekarang dan kumpulkan streak mingguan.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "rectangle.portrait.on.rectangle.portrait.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(AppPadding.areaPadding)
            .background(
                LinearGradient(
                    colors: [Color.brandColorPrimaryTeal, Color.brandColorPrimaryTeal.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
            .shadow(color: Color.brandColorPrimaryTeal.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FlashcardCTABanner(action: {})
        .padding()
}
