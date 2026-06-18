//
//  AppActivityMissionCard.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppActivityMissionCard: View {
    var title: String
    var subtitle: String
    var isCompleted: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.brandColorPrimaryTeal : Color(UIColor.tertiarySystemFill))
                    .frame(width: 40, height: 40)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(AppPadding.shapePadding)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(isCompleted ? 0.6 : 1.0)
    }
}

#Preview {
    VStack {
        AppActivityMissionCard(
            title: "Lakukan Flashcard",
            subtitle: "Mainkan hari ini untuk menjaga streak",
            isCompleted: true
        )
        
        AppActivityMissionCard(
            title: "Deteksi Kosakata Baru",
            subtitle: "Temukan 1 benda baru hari ini",
            isCompleted: false
        )
    }
    .padding()
}
