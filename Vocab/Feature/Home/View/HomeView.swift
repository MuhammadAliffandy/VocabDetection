//
//  HomeView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VocabItem.createDate, order: .reverse) private var savedVocabs: [VocabItem]
    
    @AppStorage("showDemo") private var showDemo: Bool = false
    var isDemo: Bool { return showDemo }
    
    @State private var isShowingFlashcard = false
    @State private var selectedVocab: VocabItem?

    @AppStorage("lastFlashcardDate") private var lastFlashcardDate: String = ""
    @AppStorage("lastDragDropDate") private var lastDragDropDate: String = ""
    @State private var isShowingDragDrop = false

    var todayVocabs: [VocabItem] {
        let calendar = Calendar.current
        return savedVocabs.filter { calendar.isDateInToday($0.createDate) }
    }
    
    var todayVocabCount: Int {
        return todayVocabs.count
    }

    var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: .now)
    }

    var hasPlayedFlashcardToday: Bool { lastFlashcardDate == todayString }
    var hasPlayedDragDropToday: Bool { lastDragDropDate == todayString }

    let gridColumns = [
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Color.clear.frame(height: 12)
                        
                        if !savedVocabs.isEmpty {
                            AppHeadline(
                                title: "Jumlah kosakata kamu",
                                subtitle: "Jumlah kosakata yang sudah kamu simpan",
                                titleStyle: .appTitle,
                                subtitleStyle: .appHeadline,
                                titleColor: .primary,
                                aligment: .leading,
                                spacing: AppSpacing.textSpacing
                            )

                            LazyVGrid(columns: gridColumns, spacing: AppSpacing.medium) {
                                AppVocabDashboardCard(
                                    icon: AppIcon.BookPagesIcon,
                                    title: "Total",
                                    subtitle: "Kosakata",
                                    count: "\(savedVocabs.count)"
                                )
                                
                                AppVocabDashboardCard(
                                    icon: AppIcon.ClockBadgeCheckmarkIcon,
                                    title: "Kosakata",
                                    subtitle: "Hari ini",
                                    count: "\(todayVocabCount)"
                                )
                            }
                        } else {
                            // Show empty state for flashcard
                            VStack(spacing: AppSpacing.medium) {
                                Spacer().frame(height: 40)
                                AppEmptyState(
                                    icon: AppIcon.CameraApertureIcon,
                                    title: "Mulai Belajar",
                                    subtitle: "Ambil foto benda di sekitarmu dengan kamera untuk bisa mulai belajar."
                                )
                            }
                        }
                        
                        AppInteractiveFeatureSection(
                            items: [
                                AppInteractiveFeatureItem(
                                    title: "Flashcard",
                                    subtitle: "Mengingat arti dan cara pengucapan dari kosakata",
                                    imageName: AppImageAsset.imgFlashcard,
                                    gradient: [
                                        Color(red: 0.13, green: 0.69, blue: 0.67),
                                        Color(red: 0.09, green: 0.50, blue: 0.55)
                                    ],
                                    isCompleted: hasPlayedFlashcardToday,
                                    isActive: !savedVocabs.isEmpty,
                                    action: { isShowingFlashcard = true }
                                ),
                                AppInteractiveFeatureItem(
                                    title: "Lengkapi kalimat",
                                    subtitle: "Melengkapi kalimat dengan kosakata kamu",
                                    imageName: AppImageAsset.imgFillVocab,
                                    gradient: [
                                        Color(red: 0.93, green: 0.65, blue: 0.13),
                                        Color(red: 0.80, green: 0.50, blue: 0.05)
                                    ],
                                    isCompleted: hasPlayedDragDropToday,
                                    isActive: !savedVocabs.isEmpty,
                                    action: { isShowingDragDrop = true }
                                )
                            ],
                            spacing: AppSpacing.medium
                        )

                        
                        Spacer()
                            .frame(height: 16)
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, AppPadding.areaPadding)
                .padding(.bottom, AppPadding.areaPadding)
                
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .fullScreenCover(isPresented: $isShowingFlashcard) {
                FlashcardView()
            }
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $isShowingDragDrop) {
                DragDropGameView()
            }
            .navigationDestination(item: $selectedVocab) { vocab in
                let sentences = vocab.sentences.map {
                    GeneratedSentence(type: $0.type, text: $0.text, meaning: $0.meaning)
                }
                let dictToInject = vocab.vocabDictionary.isEmpty
                    ? [vocab.textVocab.lowercased(): vocab.textMeaning]
                    : vocab.vocabDictionary
                    
                ResultView(
                    isFromHome: true,
                    detectedObjects: [vocab.textVocab],
                    capturedImageData: vocab.imageData,
                    injectedSentences: sentences,
                    injectedVocab: dictToInject
                )
            }
        }
    }
}

#Preview {
    HomeView()
}
