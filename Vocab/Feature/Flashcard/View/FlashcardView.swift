//
//  FlashcardView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI
import SwiftData
import AVFoundation

struct FlashcardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \VocabItem.createDate, order: .reverse) private var savedVocabs: [VocabItem]
    
    @State private var currentIndex: Int = 0
    @State private var isFinished: Bool = false
    
    // Store states for cards
    @State private var flippedStates: [Int: Bool] = [:]
    @State private var offsetStates: [Int: CGSize] = [:]
    
    @AppStorage("lastFlashcardDate") private var lastFlashcardDate: String = ""
    @AppStorage("lastDragDropDate") private var lastDragDropDate: String = ""
    
    // Speech synthesizer for TTS
    private let synthesizer = AVSpeechSynthesizer()
    
    // For completion animation
    @State private var showConfetti = false
    @State private var showHalfCompleteToast = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if savedVocabs.isEmpty {
                    AppHeadline(
                        title: "Belum Ada Kosakata",
                        subtitle: "Kamu butuh setidaknya 1 kosakata untuk main.",
                        titleStyle: .appHeadline,
                        subtitleStyle: .appSubheadline,
                        titleColor: .primary,
                        aligment: .center,
                        spacing: 8,
                        textAlign: .center
                    )
                } else if isFinished {
                    VStack(spacing: AppSpacing.medium) {
                        if showConfetti {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.brandColorPrimaryTeal)
                            
                            AppHeadline(
                                title: "Streak Tercapai! 🔥",
                                subtitle: "Luar biasa! Kamu menyelesaikan 2/2 aktivitas hari ini.",
                                titleStyle: .appHeadlinev2,
                                subtitleStyle: .appHeadline,
                                titleColor: .primary,
                                aligment: .center,
                                spacing: 8,
                                textAlign: .center
                            )
                        } else {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.brandColorPrimaryTeal)
                            
                            AppHeadline(
                                title: "1/2 Aktivitas Selesai",
                                subtitle: "Hebat! Lanjutkan ke Drag & Drop untuk menjaga streak.",
                                titleStyle: .appHeadlinev2,
                                subtitleStyle: .appHeadline,
                                titleColor: .primary,
                                aligment: .center,
                                spacing: 8,
                                textAlign: .center
                            )
                        }
                        
                        AppGlassButton(icon: AppIcon.XmarkIcon, text: "Tutup", action: { dismiss() }, horizontalPadding: 32, verticalPadding: 16)
                            .padding(.top, 24)
                    }
                    .padding(.horizontal, 24)
                } else {
                    VStack {
                        // Max 3 cards in the stack
                        let visibleIndices = Array(currentIndex..<min(currentIndex + 3, savedVocabs.count))
                        
                        ZStack {
                            ForEach(visibleIndices.reversed(), id: \.self) { index in
                                let vocab = savedVocabs[index]
                                let isFlipped = flippedStates[index] ?? false
                                let dragOffset = offsetStates[index] ?? .zero
                                let cardIndex = index - currentIndex // 0 for top card, 1 for second...
                                
                                // Calculate scale and offset for stacked effect
                                let scale = 1.0 - CGFloat(cardIndex) * 0.05
                                let yOffset = CGFloat(cardIndex) * 15.0
                                
                                FlashcardSingleCard(
                                    vocab: vocab,
                                    isFlipped: isFlipped,
                                    speakAction: { speak(text: vocab.textVocab) }
                                )
                                .frame(width: 300, height: 400)
                                .scaleEffect(scale)
                                .offset(y: yOffset)
                                .offset(x: dragOffset.width, y: dragOffset.height)
                                .rotationEffect(.degrees(Double(dragOffset.width / 15)))
                                .opacity(cardIndex > 2 ? 0 : 1)
                                .animation(.spring(), value: offsetStates[index])
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            // Only top card can be dragged
                                            if cardIndex == 0 {
                                                offsetStates[index] = value.translation
                                            }
                                        }
                                        .onEnded { value in
                                            if cardIndex == 0 {
                                                handleSwipe(translation: value.translation, index: index)
                                            }
                                        }
                                )
                                .onTapGesture(count: 2) {
                                    if cardIndex == 0 {
                                        flipCard(at: index)
                                    }
                                }
                                .onTapGesture(count: 1) {
                                    if cardIndex == 0 {
                                        speak(text: vocab.textVocab)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppPadding.areaPadding)
                        .padding(.vertical, 32)
                        
                        Spacer()
                        
                        // Bottom Tip
                        Text("Geser Kanan: Ingat  •  Geser Kiri: Lupa\nDouble Tap untuk balik  •  Single Tap untuk dengar suara")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Tutup") {
                        dismiss()
                    }
                    .foregroundColor(.brandColorPrimaryTeal)
                }
            }
            .onDisappear {
                if synthesizer.isSpeaking {
                    synthesizer.stopSpeaking(at: .immediate)
                }
            }
        }
    }
    
    private func flipCard(at index: Int) {
        let isCurrentlyFlipped = flippedStates[index] ?? false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            flippedStates[index] = !isCurrentlyFlipped
        }
    }
    
    private func handleSwipe(translation: CGSize, index: Int) {
        let swipeThreshold: CGFloat = 100
        
        if translation.width > swipeThreshold {
            // Swipe Right: Ingat
            withAnimation(.easeOut(duration: 0.3)) {
                offsetStates[index] = CGSize(width: 500, height: 0)
            }
            moveToNextCard()
        } else if translation.width < -swipeThreshold {
            // Swipe Left: Lupa
            withAnimation(.easeOut(duration: 0.3)) {
                offsetStates[index] = CGSize(width: -500, height: 0)
            }
            moveToNextCard()
        } else {
            // Reset position if not swiped far enough
            withAnimation(.spring()) {
                offsetStates[index] = .zero
            }
        }
    }
    
    private func moveToNextCard() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                if currentIndex < savedVocabs.count - 1 {
                    currentIndex += 1
                } else {
                    finishSession()
                }
            }
        }
    }
    
    private func speak(text: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category.")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Assuming vocab is English
        utterance.rate = 0.4
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        synthesizer.speak(utterance)
    }
    
    private func finishSession() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: .now)
        
        lastFlashcardDate = todayStr
        
        if lastDragDropDate == todayStr {
            // Both completed! Save streak and show confetti
            saveStreak()
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            showConfetti = true
        } else {
            showHalfCompleteToast = true
        }
        
        withAnimation {
            isFinished = true
        }
    }
    
    private func saveStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: .now)
        
        let descriptor = FetchDescriptor<DailyStreak>()
        if let streaks = try? modelContext.fetch(descriptor) {
            if !streaks.contains(where: { $0.dateString == todayStr }) {
                let newStreak = DailyStreak(date: .now)
                modelContext.insert(newStreak)
                try? modelContext.save()
            }
        }
    }
}

// Subcomponent for the actual card UI
struct FlashcardSingleCard: View {
    var vocab: VocabItem
    var isFlipped: Bool
    var speakAction: () -> Void
    
    @State private var cachedImage: UIImage?
    
    var body: some View {
        ZStack {
            // Front of Card
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 20) {
                    if let image = cachedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    } else if vocab.imageData != nil {
                        // Loading placeholder
                        ProgressView()
                            .frame(width: 200, height: 200)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
                    }
                    
                    Text(vocab.textVocab)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            
            // Back of Card
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.brandColorPrimaryTeal)
                    .shadow(color: .brandColorPrimaryTeal.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 24) {
                    Text(vocab.textMeaning)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if !vocab.textIPA.isEmpty {
                        Text(vocab.textIPA)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Button(action: speakAction) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.brandColorPrimaryTeal)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
        }
        .task {
            if let imgData = vocab.imageData, cachedImage == nil {
                // Decode in background to prevent frame drops during drag animations
                let image = await Task.detached(priority: .userInitiated) {
                    return UIImage(data: imgData)
                }.value
                
                await MainActor.run {
                    self.cachedImage = image
                }
            }
        }
    }
}

#Preview {
    FlashcardView()
}
