//
//  WeeklyStreakTracker.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI
import SwiftData

struct WeeklyStreakTracker: View {
    @Query private var streaks: [DailyStreak]
    @Query(sort: \VocabItem.createDate, order: .reverse) private var savedVocabs: [VocabItem]
    
    @State private var isExpanded: Bool = false
    @State private var showRecentProgress: Bool = false
    @State private var selectedDate: Date = .now
    
    @State private var referenceDate: Date = .now
    
    // Check if a specific date is in the streaks
    private func hasStreak(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return streaks.contains(where: { $0.dateString == dateString })
    }
    
    // Get dates depending on expansion
    private var displayedDates: [Date] {
        let calendar = Calendar.current
        let daysCount = isExpanded ? 28 : 7
        var dates: [Date] = []
        // Change to referenceDate
        for i in (0..<daysCount).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: referenceDate) {
                dates.append(date)
            }
        }
        return dates
    }
    
    // Helper to get day number (e.g., "14")
    private func dateNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // Helper to get day name initials (e.g., "S", "M", "T")
    private func dayInitial(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "E"
        let dayStr = formatter.string(from: date)
        return String(dayStr.prefix(1)).uppercased()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.textSpacing) {
            HStack {
                AppHeadline(
                    title: "Streak Belajar",
                    subtitle: isExpanded ? "Riwayat belajar Anda" : "Mainkan flashcard setiap hari!",
                    titleStyle: .appHeadline,
                    subtitleStyle: .appSubheadline,
                    titleColor: .primary,
                    aligment: .leading,
                    spacing: 2
                )
                
                Spacer()
                
                if isExpanded {
                    DatePicker(
                        "",
                        selection: $referenceDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .tint(.brandColorPrimaryTeal)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.brandColorPrimaryTeal)
                }
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                    ForEach(displayedDates, id: \.self) { date in
                        let isCompleted = hasStreak(on: date)
                        let isToday = Calendar.current.isDateInToday(date)
                        
                        Button(action: {
                            if isExpanded {
                                selectedDate = date
                                showRecentProgress = true
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(dayInitial(for: date))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.gray)
                                
                                ZStack {
                                    if isCompleted {
                                        // Streak achieved! Show Flame with colored background
                                        Circle()
                                            .fill(Color.brandColorPrimaryTeal)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    } else {
                                        // Default Circle with Date Number
                                        Circle()
                                            .fill(isToday ? Color.brandColorPrimaryTeal.opacity(0.2) : Color(UIColor.tertiarySystemFill))
                                            .frame(width: 40, height: 40)
                                        
                                        Text(dateNumber(for: date))
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(isToday ? .brandColorPrimaryTeal : .primary)
                                    }
                                }
                                .overlay {
                                    if isToday && !isCompleted {
                                        Circle()
                                            .stroke(Color.brandColorPrimaryTeal, lineWidth: 2)
                                            .scaleEffect(1.1)
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!isExpanded)
                    }
                }
                .padding(.vertical, AppSpacing.textSpacing)
                
            }
            .padding(AppPadding.shapePadding)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        }
        .sheet(isPresented: $showRecentProgress) {
            RecentProgressSheet(vocabs: savedVocabs, selectedDate: selectedDate)
        }
    }
}

struct RecentProgressSheet: View {
    let vocabs: [VocabItem]
    let selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var filteredVocabs: [VocabItem] {
        let calendar = Calendar.current
        return vocabs.filter { calendar.isDate($0.createDate, inSameDayAs: selectedDate) }
    }
    
    var headerTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMM" // E.g., "14 Feb"
        return "Progress \(formatter.string(from: selectedDate))"
    }
    
    let gridColumns = [
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.medium) {
                    if filteredVocabs.isEmpty {
                        AppHeadline(
                            title: "Belum Ada",
                            subtitle: "Kamu belum mendeteksi kosakata pada tanggal ini.",
                            titleStyle: .appHeadlinev2,
                            subtitleStyle: .appHeadline,
                            titleColor: .primary,
                            aligment: .center,
                            spacing: AppSpacing.textSpacing,
                            textAlign: .center
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: gridColumns, spacing: AppSpacing.medium) {
                            ForEach(filteredVocabs) { item in
                                AppVocabCard(
                                    image: AppImageAsset.dummyImage,
                                    imageData: item.imageData,
                                    title: item.textVocab,
                                    subtitle: item.textMeaning,
                                    isEditingMode: false,
                                    isSelected: false,
                                    onTapGesture: {},
                                    onLongPressGesture: {}
                                )
                            }
                        }
                        .padding(AppPadding.areaPadding)
                    }
                }
            }
            .navigationTitle(headerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    WeeklyStreakTracker()
}
