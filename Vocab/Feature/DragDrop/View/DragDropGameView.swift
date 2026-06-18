//
//  DragDropGameView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 18/06/26.
//

import SwiftUI
import SwiftData

struct DragDropGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedVocabs: [VocabItem]
    
    @State private var currentVocab: VocabItem?
    @State private var currentSentence: VocabSentence?
    @State private var options: [String] = []
    
    @State private var isDropped: Bool = false
    @State private var isCorrect: Bool = false
    @State private var showFeedback: Bool = false
    @State private var droppedWord: String? = nil
    
    @State private var gameCompleted: Bool = false
    
    @AppStorage("lastDragDropDate") private var lastDragDropDate: String = ""
    @AppStorage("lastFlashcardDate") private var lastFlashcardDate: String = ""
    
    // For Confetti & Toast Notification logic
    var onComplete: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                let todayStr = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: .now)
                }()
                let showConfetti = (lastFlashcardDate == todayStr)
                
                if gameCompleted {
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
                                subtitle: "Hebat! Lanjutkan ke Flashcard untuk menjaga streak.",
                                titleStyle: .appHeadlinev2,
                                subtitleStyle: .appHeadline,
                                titleColor: .primary,
                                aligment: .center,
                                spacing: 8,
                                textAlign: .center
                            )
                        }
                        
                        AppGlassButton(
                            icon: AppIcon.XmarkIcon,
                            text: "Tutup",
                            action: {
                                markCompletedAndDismiss()
                            },
                            horizontalPadding: 30,
                            verticalPadding: 15
                        )
                        .padding(.top, 24)
                    }
                    .padding(.horizontal, 24)
                } else if let vocab = currentVocab, let sentence = currentSentence {
                    VStack(spacing: 30) {
                        
                        Text("Lengkapi Kalimat")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                        
                        // Sentence Target Area
                        SentenceDropArea(
                            sentence: sentence.text,
                            vocabWord: vocab.textVocab,
                            droppedWord: droppedWord,
                            isDropped: isDropped,
                            isCorrect: isCorrect,
                            onRemove: {
                                withAnimation(.spring()) {
                                    self.droppedWord = nil
                                    self.isDropped = false
                                    self.showFeedback = false
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        if showFeedback {
                            Text(isCorrect ? "Benar! Luar biasa 🎉" : "Salah, coba lagi!")
                                .font(.headline)
                                .foregroundColor(isCorrect ? .green : .red)
                                .animation(.spring(), value: showFeedback)
                                
                            if isCorrect {
                                Text(sentence.meaning)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 5)
                            }
                        }
                        
                        // Options Area
                        HStack(spacing: 15) {
                            ForEach(options, id: \.self) { option in
                                if option != droppedWord {
                                    DraggableWordOption(word: option) {
                                        handleDrop(option: option, correctWord: vocab.textVocab)
                                    }
                                } else {
                                    // Placeholder
                                    Color.clear
                                        .frame(width: 100, height: 50)
                                }
                            }
                        }
                        .frame(height: 50)
                        .padding(.bottom, 50)
                    }
                } else {
                    VStack(spacing: 15) {
                        Text("Tidak ada data cukup.")
                            .font(.headline)
                        Text("Silakan deteksi vocab dan kalimat terlebih dahulu.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        AppGlassButton(icon: AppIcon.XmarkIcon, action: { dismiss() }, horizontalPadding: 20, verticalPadding: 15)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") { dismiss() }
                }
            }
            .onAppear {
                setupGame()
            }
        }
    }
    
    @State private var rounds: [(vocab: VocabItem, sentence: VocabSentence)] = []
    @State private var currentRoundIndex: Int = 0
    
    private func setupGame() {
        // Find vocabs that have sentences
        let availableVocabs = savedVocabs.filter { !$0.sentences.isEmpty }.shuffled()
        
        var newRounds: [(VocabItem, VocabSentence)] = []
        let maxRounds = min(5, availableVocabs.count)
        
        for i in 0..<maxRounds {
            let vocab = availableVocabs[i]
            if let randomSentence = vocab.sentences.randomElement() {
                newRounds.append((vocab, randomSentence))
            }
        }
        
        if newRounds.isEmpty {
            return
        }
        
        self.rounds = newRounds
        self.currentRoundIndex = 0
        loadRound(index: 0)
    }
    
    private func loadRound(index: Int) {
        let round = rounds[index]
        self.currentVocab = round.vocab
        self.currentSentence = round.sentence
        
        var newOptions = [round.vocab.textVocab]
        let otherVocabs = savedVocabs.filter { $0.id != round.vocab.id }.shuffled()
        for v in otherVocabs.prefix(2) {
            newOptions.append(v.textVocab)
        }
        
        self.options = newOptions.shuffled()
        
        withAnimation {
            self.droppedWord = nil
            self.isDropped = false
            self.isCorrect = false
            self.showFeedback = false
        }
    }
    
    private func handleDrop(option: String, correctWord: String) {
        withAnimation(.spring()) {
            droppedWord = option
            isDropped = true
            isCorrect = (option.lowercased() == correctWord.lowercased())
            showFeedback = true
        }
        
        if isCorrect {
            // Sukses
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                if currentRoundIndex < rounds.count - 1 {
                    currentRoundIndex += 1
                    loadRound(index: currentRoundIndex)
                } else {
                    finishSession()
                }
            }
        } else {
            // Salah, biarkan di atas sejenak, lalu beri feedback dan bisa diturunkan,
            // atau otomatis snap back setelah 1.5 detik
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // If it wasn't already removed manually by user
                if droppedWord == option {
                    withAnimation(.spring()) {
                        droppedWord = nil
                        isDropped = false
                        showFeedback = false
                    }
                }
            }
        }
    }
    
    private func finishSession() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: .now)
        lastDragDropDate = todayStr
        
        if lastFlashcardDate == todayStr {
            // Both completed! Save streak
            saveStreak()
        }
        
        withAnimation {
            gameCompleted = true
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
    
    private func markCompletedAndDismiss() {
        dismiss()
    }
}

struct SentenceDropArea: View {
    var sentence: String
    var vocabWord: String
    var droppedWord: String?
    var isDropped: Bool
    var isCorrect: Bool
    var onRemove: () -> Void
    
    var body: some View {
        // Split sentence to find where the vocab word is and replace it with blank
        let components = sentence.lowercased().components(separatedBy: vocabWord.lowercased())
        
        VStack(spacing: 20) {
            if components.count > 1 {
                // If the word was found perfectly
                VStack(spacing: 10) {
                    Text(components[0].capitalized)
                        .font(.title2)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isDropped ? (isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.gray.opacity(0.1))
                            .frame(width: 150, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isDropped ? (isCorrect ? Color.green : Color.red) : Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: isDropped ? [] : [5]))
                            )
                        
                        if isDropped, let text = droppedWord {
                            Text(text)
                                .font(.title2).bold()
                                .foregroundColor(isCorrect ? .green : .red)
                                .onTapGesture {
                                    if !isCorrect {
                                        onRemove()
                                    }
                                }
                        } else {
                            Text("Tarik Kesini")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(components[1])
                        .font(.title2)
                }
                .multilineTextAlignment(.center)
            } else {
                // Fallback if exact word not matched due to punctuation
                Text(sentence)
                    .font(.title2)
                    .blur(radius: isDropped ? 0 : 5)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isDropped ? (isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : Color.gray.opacity(0.1))
                        .frame(width: 150, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isDropped ? (isCorrect ? Color.green : Color.red) : Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: isDropped ? [] : [5]))
                        )
                    
                    if isDropped, let text = droppedWord {
                        Text(text)
                            .font(.title2).bold()
                            .foregroundColor(isCorrect ? .green : .red)
                            .onTapGesture {
                                if !isCorrect {
                                    onRemove()
                                }
                            }
                    } else {
                        Text("Tarik Kesini")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(30)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct DraggableWordOption: View {
    var word: String
    var onDrop: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        Text(word)
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(Color.brandColorPrimaryTeal)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(color: .brandColorPrimaryTeal.opacity(0.3), radius: 5, x: 0, y: 5)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        // Simple drop zone detection based on vertical drag
                        if value.translation.height < -100 {
                            onDrop()
                        }
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
            )
            .zIndex(dragOffset == .zero ? 0 : 1)
    }
}

#Preview {
    DragDropGameView()
}
