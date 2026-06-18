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
    @Query private var streaks: [DailyStreak]
    
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
    
    // Streak Minggu Ini
    var weeklyStreakCount: Int {
        let calendar = Calendar.current
        guard let aWeekAgo = calendar.date(byAdding: .day, value: -7, to: .now) else { return 0 }
        return streaks.filter { $0.timestamp >= aWeekAgo }.count
    }
    
    // Aktivitas Minggu Ini (dummy count based on vocabs + streaks for now, since we only track completed days)
    var weeklyActivityCount: Int {
        let calendar = Calendar.current
        guard let aWeekAgo = calendar.date(byAdding: .day, value: -7, to: .now) else { return 0 }
        let vocabsThisWeek = savedVocabs.filter { $0.createDate >= aWeekAgo }.count
        return vocabsThisWeek + weeklyStreakCount * 2
    }
    
    var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: .now)
    }
    
    var hasPlayedFlashcardToday: Bool {
        return lastFlashcardDate == todayString
    }
    
    var hasPlayedDragDropToday: Bool {
        return lastDragDropDate == todayString
    }

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
                    VStack(spacing: AppSpacing.medium) {
                        Color.clear.frame(height: 12)
                        
                        if !savedVocabs.isEmpty {
                            WeeklyStreakTracker()
                            
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
                                
                                AppVocabDashboardCard(
                                    icon: "flame.fill",
                                    title: "Streak",
                                    subtitle: "Minggu ini",
                                    count: "\(weeklyStreakCount)"
                                )
                                
                                AppVocabDashboardCard(
                                    icon: "gamecontroller.fill",
                                    title: "Aktivitas",
                                    subtitle: "Minggu ini",
                                    count: "\(weeklyActivityCount)"
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: AppSpacing.regular) {
                                AppHeadline(
                                    title: "Aktivitas Hari Ini",
                                    subtitle: "Selesaikan 2 misi untuk streak!",
                                    titleStyle: .appHeadlinev2,
                                    subtitleStyle: .appHeadline,
                                    titleColor: .primary,
                                    aligment: .leading,
                                    spacing: AppSpacing.textSpacing
                                )
                                .padding(.top, AppSpacing.regular)
                                
                                AppBigMissionCard(
                                    title: "Flashcard",
                                    subtitle: "Uji ingatanmu dengan tebak kartu.",
                                    backgroundColor: .brandColorPrimaryTeal,
                                    iconName: "brain.head.profile",
                                    action: { isShowingFlashcard = true },
                                    isCompleted: hasPlayedFlashcardToday
                                )
                                
                                AppBigMissionCard(
                                    title: "Tebak Kalimat",
                                    subtitle: "Drag & drop kata yang hilang.",
                                    backgroundColor: Color(red: 0.1, green: 0.6, blue: 0.4),
                                    iconName: "text.cursor",
                                    action: { isShowingDragDrop = true },
                                    isCompleted: hasPlayedDragDropToday
                                )
                            }
                        } else {
                            // Show empty state for flashcard
                            VStack(spacing: AppSpacing.medium) {
                                AppHeadline(
                                    title: "Mulai Bermain",
                                    subtitle: "Ambil foto kosakata baru untuk bisa memainkan flashcard.",
                                    titleStyle: .appHeadline,
                                    subtitleStyle: .appSubheadline,
                                    titleColor: .primary,
                                    aligment: .center,
                                    spacing: AppSpacing.textSpacing,
                                    textAlign: .center
                                )
                                .padding(.top, AppSpacing.medium)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, AppPadding.areaPadding)
                .padding(.bottom, AppPadding.areaPadding)
                .disabled(isDemo)
                
                if isDemo {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                }
                
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
