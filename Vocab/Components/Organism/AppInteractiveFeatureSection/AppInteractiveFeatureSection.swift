//
//  AppInteractiveFeatureSection.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 20/06/26.
//

import SwiftUI

struct AppInteractiveFeatureItem {
    let title: String
    let subtitle: String
    let imageName: String
    let gradient: [Color]
    let isCompleted: Bool
    var isActive: Bool = true
    let action: () -> Void
}

struct AppInteractiveFeatureSection: View {

    var items: [AppInteractiveFeatureItem]
    var spacing: CGFloat = AppSpacing.medium

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.regular) {
            // Section header
            AppHeadline(
                title: "Latihan",
                subtitle: "Latihan pakai kosakata yang udah kamu simpan",
                titleStyle: .appTitle,
                subtitleStyle: .appHeadline,
                titleColor: .primary,
                subtitleColor: Color.textColorSecondaryBlackGrey,
                aligment: .leading,
                spacing: AppSpacing.textSpacing
            )
            .padding(.top, AppSpacing.regular)

            // Feature cards
            VStack(spacing: spacing) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    AppInteractiveFeatureCard(item: item)
                }
            }
        }
    }
}

struct AppInteractiveFeatureCard: View {
    let item: AppInteractiveFeatureItem
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if item.isActive {
                item.action()
            }
        }) {
            ZStack(alignment: .leading) {
                // Gradient background
                LinearGradient(
                    colors: item.isActive ? item.gradient : [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius * 1.5))
                
                // Subtle inner highlight
                RoundedRectangle(cornerRadius: AppRadius.shapeRadius * 1.5)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                
                // Decorative circles
                Circle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 120, height: 120)
                    .offset(x: 200, y: -30)
                
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 80, height: 80)
                    .offset(x: 230, y: 40)
                
                HStack(alignment: .center, spacing: 0) {
                    // Left content
                    VStack(alignment: .leading, spacing: 10) {
                        // Title
                        Text(item.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        // Subtitle
                        Text(item.subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // CTA Button
                        HStack(spacing: 6) {
                            if !item.isActive {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Terkunci")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            } else {
                                Text("Mulai")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(item.isActive ? (item.gradient.first ?? .teal) : .gray)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                    .padding(.leading, 20)
                    .padding(.vertical, 22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Right image
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(.trailing, 20)
                        .opacity(item.isActive ? 1.0 : 0.6)
                        .saturation(item.isActive ? 1.0 : 0.0)
                }
                .frame(height: 165)
                .shadow(
                    color: item.isActive ? (item.gradient.first ?? .clear).opacity(0.3) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .disabled(!item.isActive)
    }
    
    #Preview {
        ScrollView {
            AppInteractiveFeatureSection(items: [
                AppInteractiveFeatureItem(
                    title: "Flashcard",
                    subtitle: "Mengingat arti dan cara pengucapan dari kosakata",
                    imageName: AppImageAsset.imgFlashcard,
                    gradient: [Color(red: 0.13, green: 0.69, blue: 0.67), Color(red: 0.09, green: 0.50, blue: 0.55)],
                    isCompleted: false,
                    isActive: false,
                    action: {}
                ),
                AppInteractiveFeatureItem(
                    title: "Lengkapi kalimat",
                    subtitle: "Melengkapi kalimat dengan kosakata kamu",
                    imageName: AppImageAsset.imgFillVocab,
                    gradient: [Color(red: 0.93, green: 0.65, blue: 0.13), Color(red: 0.80, green: 0.50, blue: 0.05)],
                    isCompleted: false,
                    isActive: true,
                    action: {}
                )
            ])
            .padding()
        }
    }
}
