import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DragDropGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedVocabs: [VocabItem]
    
    @State private var rounds: [(vocab: VocabItem, sentence: VocabSentence)] = []
    @State private var roundStates: [RoundState] = []
    @State private var sharedOptions: [String] = []
    
    // Manual Drag and Drop state
    @State private var dropZoneFrames: [Int: CGRect] = [:]
    @State private var activeDragOption: String? = nil
    @State private var activeDragPosition: CGPoint = .zero
    
    @State private var showCongratsModal = false
    @AppStorage("lastDragDropDate") private var lastDragDropDate: String = ""
    @AppStorage("lastFlashcardDate") private var lastFlashcardDate: String = ""
    @AppStorage("inDemoFlow") private var inDemoFlow: Bool = false
    @AppStorage("isShowingDragDropDemo") private var isShowingDragDropDemo: Bool = false
    var onComplete: () -> Void = {}
    
    struct RoundState {
        var droppedWord: String? = nil
        var isDropped: Bool = false
        var isCorrect: Bool = false
    }
    
    var allCompleted: Bool {
        !roundStates.isEmpty && roundStates.allSatisfy { $0.isCorrect }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            let todayStr = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: .now)
            }()
            let showConfetti = (lastFlashcardDate == todayStr)
            
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    // Balancer for centering
                    Color.clear.frame(width: 44, height: 44)
                    
                    Spacer()
                    
                    AppHeadline(
                        title: "Lengkapi Kalimat",
                        subtitle: "Lengkapi kalimatnya! Tekan, tahan, lalu seret kata yang tepat ke kotak yang kosong",
                        aligment: .center,
                        textAlign: .center
                    )
                    
                    Spacer()
                    
                    AppGlassButton(icon: AppIcon.XmarkIcon, action: { dismiss() }, horizontalPadding: 12, verticalPadding: 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                if !rounds.isEmpty {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(rounds.enumerated()), id: \.offset) { i, round in
                                let state = i < roundStates.count ? roundStates[i] : RoundState()
                                AppSentenceDropArea(
                                    roundIndex: i,
                                    sentence: round.sentence.text,
                                    vocabWord: round.vocab.textVocab,
                                    missingWordMeaning: round.vocab.textMeaning,
                                    meaning: round.sentence.meaning,
                                    droppedWord: state.droppedWord,
                                    isDropped: state.isDropped,
                                    isCorrect: state.isCorrect,
                                    vocabDictionary: round.vocab.vocabDictionary,
                                    onRemove: {
                                        withAnimation(.spring()) {
                                            if i < roundStates.count {
                                                roundStates[i].droppedWord = nil
                                                roundStates[i].isDropped = false
                                                roundStates[i].isCorrect = false
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.top, 40)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 140)
                    }
                    .scrollIndicators(.hidden)
                    
                    // Sticky Bottom Options
                    VStack(spacing: 10) {
                        AppFlowLayout(spacing: 12) {
                            ForEach(sharedOptions, id: \.self) { option in
                                let isUsed = roundStates.contains { $0.droppedWord?.lowercased() == option.lowercased() && $0.isCorrect }
                                
                                if !isUsed {
                                    AppDraggableWordOption(word: option)
                                        .opacity(activeDragOption == option ? 0.0 : 1.0)
                                        .gesture(
                                            DragGesture(coordinateSpace: .named("GameSpace"))
                                                .onChanged { value in
                                                    activeDragOption = option
                                                    activeDragPosition = value.location
                                                }
                                                .onEnded { value in
                                                    let dropPoint = value.location
                                                    var droppedIdx: Int? = nil
                                                    
                                                    for (idx, frame) in dropZoneFrames {
                                                        if frame.contains(dropPoint) {
                                                            droppedIdx = idx
                                                            break
                                                        }
                                                    }
                                                    
                                                    if let idx = droppedIdx {
                                                        handleDropForRound(roundIndex: idx, option: option)
                                                    }
                                                    
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        activeDragOption = nil
                                                    }
                                                }
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 40)
                        
                        AppEmptyState(
                            icon: "text.insert",
                            title: "Tidak ada data cukup",
                            subtitle: "Silakan deteksi vocab dan kalimat terlebih dahulu dari kamera."
                        )
                        
                        AppGlassButton(icon: AppIcon.XmarkIcon, action: { dismiss() }, horizontalPadding: 20, verticalPadding: 15)
                    }
                }
            } // VStack
            
            // Drag Overlay
            if let draggedOption = activeDragOption {
                AppDraggableWordOption(word: draggedOption)
                    .position(activeDragPosition)
                    .allowsHitTesting(false)
                    .transition(.identity)
            }
        } // ZStack
        .coordinateSpace(name: "GameSpace")
        .onPreferenceChange(DropZoneFramePreferenceKey.self) { frames in
            dropZoneFrames = frames
        }
        .onAppear {
            setupGame()
        }
        .sheet(isPresented: $showCongratsModal) {
            let todayStr = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: .now)
            }()
            let showConfetti = (lastFlashcardDate == todayStr)
            
            AppCongratsModal(
                title: "Luar Biasa!",
                subtitle: "Kamu berhasil menyelesaikan semua soal.",
                icon: "checkmark.circle.fill",
                iconColor: Color.brandColorPrimaryTeal,
                onSelesai: {
                    showCongratsModal = false
                    if inDemoFlow && isShowingDragDropDemo {
                        isShowingDragDropDemo = false
                        inDemoFlow = false
                    } else {
                        dismiss()
                    }
                },
                onCobaLagi: {
                    showCongratsModal = false
                    setupGame()
                }
            )
        }
    } // body
    
    private func setupGame() {
        let availableVocabs = savedVocabs.filter { !$0.sentences.isEmpty }.shuffled()
        var newRounds: [(vocab: VocabItem, sentence: VocabSentence)] = []
        let maxRounds = min(3, availableVocabs.count)
        
        for i in 0..<maxRounds {
            let vocab = availableVocabs[i]
            if let randomSentence = vocab.sentences.randomElement() {
                newRounds.append((vocab: vocab, sentence: randomSentence))
            }
        }
        
        if newRounds.isEmpty { return }
        
        self.rounds = newRounds
        self.roundStates = Array(repeating: RoundState(), count: newRounds.count)
        
        let allAnswers = newRounds.map { $0.vocab.textVocab }
        self.sharedOptions = Array(Set(allAnswers)).shuffled()
    }
    
    private func handleDropForRound(roundIndex: Int, option: String) {
        guard roundIndex < rounds.count, roundIndex < roundStates.count else { return }
        let correctWord = rounds[roundIndex].vocab.textVocab
        let correct = option.lowercased() == correctWord.lowercased()
        
        withAnimation(.spring()) {
            roundStates[roundIndex].droppedWord = option
            roundStates[roundIndex].isDropped = true
            roundStates[roundIndex].isCorrect = correct
        }
        
        if correct {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if roundStates.allSatisfy({ $0.isCorrect }) {
                    finishSession()
                }
            }
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if roundIndex < roundStates.count && !roundStates[roundIndex].isCorrect {
                    withAnimation(.spring()) {
                        roundStates[roundIndex].droppedWord = nil
                        roundStates[roundIndex].isDropped = false
                    }
                }
            }
        }
    }
    
    private func finishSession() {
        withAnimation {
            self.showCongratsModal = true
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.lastDragDropDate = formatter.string(from: .now)
        
        onComplete()
    }
}
