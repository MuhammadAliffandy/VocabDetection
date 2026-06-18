//
//  MainTabView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @AppStorage("isCameraPresented") private var isCameraPresented: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Layer
            Group {
                if selectedTab == 0 {
                    HomeView()
                } else {
                    HistoryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Floating Tab Bar Layer
            HStack(spacing: AppSpacing.medium) {
                // Left Capsule (Navigation)
                HStack(spacing: 0) {
                    TabItemButton(
                        title: "Library",
                        icon: "photo.on.rectangle", // Or "rectangle.stack.fill"
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    
                    TabItemButton(
                        title: "Collections",
                        icon: "square.stack.3d.down.right.fill",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Spacer()
                
                // Right Circle (Camera Action)
                AppCameraButton {
                    isCameraPresented = true
                }
            }
            .padding(.horizontal, AppPadding.areaPadding)
            .padding(.bottom, 20)
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraView()
        }
    }
}

// Subcomponent for Tab Button
struct TabItemButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(title)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(isSelected ? .brandColorPrimaryTeal : .gray)
            .frame(width: 80, height: 50)
            .background(isSelected ? Color(UIColor.systemBackground).opacity(0.8) : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
}
