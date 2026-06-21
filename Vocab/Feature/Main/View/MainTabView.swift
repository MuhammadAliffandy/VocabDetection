//
//  MainTabView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct MainTabView: View {
    @AppStorage("mainSelectedTab") private var selectedTab: Int = 0
    @AppStorage("isCameraPresented") private var isCameraPresented: Bool = false
    @AppStorage("showDemo") private var showDemo: Bool = false
    @AppStorage("isShowingFlashcardDemo") private var isShowingFlashcardDemo: Bool = false
    @AppStorage("isShowingDragDropDemo") private var isShowingDragDropDemo: Bool = false
    @Namespace private var animation

    var body: some View {
        ZStack {
            // Main Content Layer
            Group {
                if selectedTab == 0 {
                    HomeView()
                } else {
                    HistoryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Demo mode — dim content to focus on camera button
            if showDemo {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showDemo)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            // Custom Floating Tab Bar
            HStack(spacing: AppSpacing.medium) {
                
                if !showDemo {
                    DraggableTabCapsule(selectedTab: $selectedTab, animation: animation)
                }
                
                Spacer()
                
                // Right Camera Button — circle glass effect
                Button(action: { 
                    isCameraPresented = true
                    if showDemo {
                        showDemo = false
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(.regularMaterial)
                            .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
                            .glassEffect()
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(ScaleButtonStyle())
                .appTooltip("Ayo mulai deteksi!", isVisible: showDemo, x: -40, y: -70)
            }
            .padding(.horizontal, AppPadding.areaPadding)
            .padding(.bottom, 0)
            .padding(.top, 8)
            .background(Color.clear)
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraView()
        }
        .fullScreenCover(isPresented: $isShowingFlashcardDemo) {
            FlashcardView()
        }
        .fullScreenCover(isPresented: $isShowingDragDropDemo) {
            DragDropGameView()
        }
    }
}

// MARK: — Draggable glass segmented capsule
struct DraggableTabCapsule: View {
    @Binding var selectedTab: Int
    var animation: Namespace.ID

    private let tabCount = 2
    private let itemSize: CGFloat = 48
    private let padding: CGFloat = 4
    private let spacing: CGFloat = 4

    // Total width of the inner HStack: (items * itemSize) + (gaps * spacing)
    private var innerWidth: CGFloat {
        CGFloat(tabCount) * itemSize + CGFloat(tabCount - 1) * spacing
    }
    private var capsuleWidth: CGFloat { innerWidth + padding * 2 }

    // Live drag state
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    // Compute which tab is "live" during drag
    private var liveTab: Int {
        let step = itemSize + spacing
        let baseX = CGFloat(selectedTab) * step
        let proposed = baseX + dragOffset
        let clamped = proposed.clamped(to: 0...(CGFloat(tabCount - 1) * step))
        let index = Int((clamped / step).rounded())
        return index.clamped(to: 0...(tabCount - 1))
    }

    // Center X of indicator for live feedback
    private var indicatorX: CGFloat {
        let step = itemSize + spacing
        let baseX = CGFloat(selectedTab) * step + itemSize / 2 + padding
        let liveX = baseX + dragOffset
        let minX = itemSize / 2 + padding
        let maxX = CGFloat(tabCount - 1) * step + itemSize / 2 + padding
        return liveX.clamped(to: minX...maxX)
    }

    private let icons = ["house.fill", "photo.on.rectangle.fill"]

    var body: some View {
        ZStack(alignment: .leading) {
            // Glass capsule background
            Capsule()
                .fill(.regularMaterial)
                .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
                .glassEffect()

            // Sliding circle indicator — moves live while dragging
            Circle()
                .fill(Color.primary.opacity(0.1))
                .frame(width: itemSize, height: itemSize)
                .position(x: indicatorX, y: (itemSize + padding * 2) / 2)
                .animation(isDragging ? .interactiveSpring() : .spring(response: 0.3, dampingFraction: 0.7), value: indicatorX)

            // Icons row
            HStack(spacing: spacing) {
                ForEach(Array(icons.enumerated()), id: \.offset) { index, icon in
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor((isDragging ? liveTab : selectedTab) == index ? .primary : Color(UIColor.tertiaryLabel))
                        .frame(width: itemSize, height: itemSize)
                        .contentShape(Circle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = index
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                }
            }
            .padding(padding)
        }
        .frame(width: capsuleWidth, height: itemSize + padding * 2)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .gesture(
            DragGesture(minimumDistance: 4)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let snappedTab = liveTab
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = snappedTab
                        dragOffset = 0
                    }
                    isDragging = false
                    if snappedTab != selectedTab {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
        )
    }
}

// MARK: — Clamp helpers
extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
    }
}

extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.max(range.lowerBound, Swift.min(range.upperBound, self))
    }
}

#Preview {
    MainTabView()
}
