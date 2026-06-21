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
    @State private var showCongratsModal: Bool = false
    @State private var shuffledVocabs: [VocabItem] = []
    
    // Store states for cards
    @State private var flippedStates: [Int: Bool] = [:]
    @State private var offsetStates: [Int: CGSize] = [:]
    
    @AppStorage("lastFlashcardDate") private var lastFlashcardDate: String = ""
    @AppStorage("lastDragDropDate") private var lastDragDropDate: String = ""
    @AppStorage("inDemoFlow") private var inDemoFlow: Bool = false
    @AppStorage("isShowingFlashcardDemo") private var isShowingFlashcardDemo: Bool = false
    @AppStorage("isShowingDragDropDemo") private var isShowingDragDropDemo: Bool = false
    
    // Speech synthesizer for TTS
    private let synthesizer = AVSpeechSynthesizer()
    
    // For completion animation
    @State private var showConfetti = false
    @State private var showHalfCompleteToast = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if shuffledVocabs.isEmpty {
                AppEmptyState(
                    icon: "lanyardcard",
                    title: "Belum Ada Kosakata",
                    subtitle: "Kamu butuh setidaknya 1 kosakata untuk bermain flashcard."
                )
            } else {
                VStack {
                    // Header
                    HStack(alignment: .top) {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("Flashcard")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Geser ke kanan jika Anda mengetahui arti dan pengucapannya, atau geser ke kiri jika tidak tahu.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.leading, 40) // offset the close button space to keep it centered
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Max 3 cards in the stack
                    let visibleIndices = Array(currentIndex..<min(currentIndex + 3, shuffledVocabs.count))
                    
                    ZStack {
                        ForEach(visibleIndices.reversed(), id: \.self) { index in
                            let vocab = shuffledVocabs[index]
                            let isFlipped = flippedStates[index] ?? false
                            let dragOffset = offsetStates[index] ?? .zero
                            let cardIndex = index - currentIndex
                            
                            let scale = 1.0 - CGFloat(cardIndex) * 0.05
                            let yOffset = CGFloat(cardIndex) * 15.0
                            
                            FlashcardSingleCard(
                                vocab: vocab,
                                isFlipped: isFlipped,
                                speakAction: { speak(text: vocab.textVocab) }
                            )
                            .frame(width: 320, height: 460)
                            .scaleEffect(scale)
                            .offset(y: yOffset)
                            .offset(x: dragOffset.width, y: dragOffset.height)
                            .rotationEffect(.degrees(Double(dragOffset.width / 15)))
                            .opacity(cardIndex > 2 ? 0 : 1)
                            .animation(.spring(), value: offsetStates[index])
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
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
                            .onTapGesture {
                                if cardIndex == 0 { flipCard(at: index) }
                            }
                        }
                    }
                    .padding(.horizontal, AppPadding.areaPadding)
                    .padding(.vertical, 32)
                    
                    Spacer()
                    
                    HStack(spacing: 24) {
                        // Left Button - Forgot
                        Button {
                            let index = currentIndex
                            withAnimation(.easeOut(duration: 0.35)) {
                                offsetStates[index] = CGSize(width: -500, height: 0)
                            }
                            moveToNextCard()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.colorRedWarning)
                                .padding(16)
                                // Use systemBackground for White in Light Mode, Black in Dark Mode
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                        
                        Text("Tap kartu untuk\nmelihat artinya")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        // Right Button - Remember
                        Button {
                            let index = currentIndex
                            withAnimation(.easeOut(duration: 0.35)) {
                                offsetStates[index] = CGSize(width: 500, height: 0)
                            }
                            moveToNextCard()
                        } label: {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.brandColorPrimaryTeal)
                                .padding(16)
                                // Use systemBackground for White in Light Mode, Black in Dark Mode
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            if shuffledVocabs.isEmpty {
                shuffledVocabs = savedVocabs.shuffled()
            }
        }
        .onChange(of: savedVocabs) { _, newVocabs in
            if shuffledVocabs.isEmpty {
                shuffledVocabs = newVocabs.shuffled()
            }
        }
        .onDisappear {
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
        }
        .sheet(isPresented: $showCongratsModal) {
            AppCongratsModal(
                title: "Flashcard Selesai!",
                subtitle: "Kamu telah melatih semua kosakata hari ini.",
                icon: "star.circle.fill",
                iconColor: .brandColorPrimaryTeal,
                onSelesai: {
                    showCongratsModal = false
                    if inDemoFlow && isShowingFlashcardDemo {
                        isShowingFlashcardDemo = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            isShowingDragDropDemo = true
                        }
                    } else {
                        dismiss()
                    }
                },
                onCobaLagi: {
                    showCongratsModal = false
                    currentIndex = 0
                    flippedStates = [:]
                    offsetStates = [:]
                    shuffledVocabs = savedVocabs.shuffled()
                }
            )
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
                if currentIndex < shuffledVocabs.count - 1 {
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
            showCongratsModal = true
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
            // Front of Card (Solid Teal with Vocab text)
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.brandColorPrimaryTeal)
                    .shadow(color: Color.brandColorPrimaryTeal.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 8) {
                    Text(vocab.textVocab)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                    
                    if !vocab.textIPA.isEmpty {
                        Text(vocab.textIPA)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            
            // Back of Card (Photo with AppVocabSpeech)
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfacePrimaryLightgrey)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Photo filling the card
                if let image = cachedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 320, height: 460) // Match new card size
                } else if vocab.imageData != nil {
                    ProgressView()
                        .frame(width: 320, height: 460)
                        .background(Color.gray.opacity(0.1))
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.2))
                }
                
                // Bottom Gradient overlay
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, Color.brandColorPrimaryTeal.opacity(0.8), Color.brandColorPrimaryTeal],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 180)
                }
                
                // AppVocabSpeech component
                VStack {
                    Spacer()
                    AppVocabSpeech(
                        vocabText: vocab.textVocab,
                        meaningText: !vocab.textIPA.isEmpty ? "\(vocab.textIPA) : \(vocab.textMeaning)" : vocab.textMeaning,
                        action: speakAction
                    )
                    .padding(.bottom, 32)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
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
