//
//  AppBigMissionCard.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 18/06/26.
//

import SwiftUI

struct AppBigMissionCard: View {
    var title: String
    var subtitle: String
    var backgroundColor: Color
    var iconName: String
    var action: () -> Void
    var isCompleted: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: AppRadius.shapeRadius * 1.5)
                    .fill(backgroundColor)
                    .shadow(color: backgroundColor.opacity(0.4), radius: 10, x: 0, y: 5)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(subtitle)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                        
                        Spacer()
                        
                        if isCompleted {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Selesai")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(backgroundColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .clipShape(Capsule())
                        } else {
                            HStack(spacing: 6) {
                                Text("Mulai")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(20)
                    
                    Spacer()
                    
                    // Large icon on the right
                    Image(systemName: iconName)
                        .font(.system(size: 70))
                        .foregroundColor(.white.opacity(0.9))
                        .offset(x: 10, y: 10)
                        .rotationEffect(.degrees(-10))
                }
            }
            .frame(height: 160)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.shapeRadius * 1.5)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Custom button style for a satisfying press effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        AppBigMissionCard(
            title: "Flashcard",
            subtitle: "Uji ingatanmu hari ini.",
            backgroundColor: .blue,
            iconName: "brain.head.profile",
            action: {}
        )
        
        AppBigMissionCard(
            title: "Tebak Kalimat",
            subtitle: "Drag & drop kata yang benar.",
            backgroundColor: .green,
            iconName: "text.cursor",
            action: {},
            isCompleted: true
        )
    }
    .padding()
}
