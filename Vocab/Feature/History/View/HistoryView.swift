//
//  HistoryView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI
import SwiftData

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VocabItem.createDate, order: .reverse) private var savedVocabs: [VocabItem]
    
    @State private var isMagnifying: Bool = false
    @State private var typping: String = ""
    @State private var debouncedTypping: String = ""
    @State private var isEditing: Bool = false
    @State private var selectedItems: Set<VocabItem.ID> = []
    @State private var selectedVocab: VocabItem?
    @State private var scrollOffset: CGFloat = 0
    
    var filteredVocabs: [VocabItem] {
        if debouncedTypping.isEmpty {
            return savedVocabs
        } else {
            return savedVocabs.filter { item in
                item.textVocab.lowercased().contains(debouncedTypping.lowercased()) ||
                item.textMeaning.lowercased().contains(debouncedTypping.lowercased())
            }
        }
    }
    
    let gridColumns = [
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium),
        
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    GeometryReader { geo in
                        Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("scroll")).minY)
                    }
                    .frame(height: 0)
                    
                    VStack(spacing: AppSpacing.medium) {
                        // Grid content only
                        
                        if savedVocabs.isEmpty {
                            Spacer()
                                .frame(height: 60)
                            
                            AppEmptyState(
                                icon: "tray",
                                title: "Belum ada Kosakata",
                                subtitle: "Kosakata yang kamu pelajari akan otomatis tersimpan di sini."
                            )
                            
                        } else if filteredVocabs.isEmpty {
                            Spacer()
                                .frame(height: 60)
                                
                            AppEmptyState(
                                icon: "magnifyingglass",
                                title: "Kosakata Tidak Ditemukan",
                                subtitle: "Coba cari dengan nama atau arti yang berbeda."
                            )
                            
                        } else {
                            LazyVGrid(columns: gridColumns, spacing: AppSpacing.medium) {
                                ForEach(filteredVocabs) { item in
                                    AppVocabCard(
                                        image: AppImageAsset.dummyImage,
                                        imageData: item.imageData,
                                        title: item.textVocab,
                                        subtitle: item.textMeaning,
                                        isEditingMode: isEditing,
                                        isSelected: selectedItems.contains(item.id),
                                        onTapGesture: {
                                            if isEditing {
                                                withAnimation {
                                                    if selectedItems.contains(item.id) {
                                                        selectedItems.remove(item.id)
                                                    } else {
                                                        selectedItems.insert(item.id)
                                                    }
                                                }
                                            } else {
                                                withAnimation(.easeInOut) {
                                                    selectedVocab = item
                                                }
                                            }
                                        },
                                        onLongPressGesture: {
                                            if !isEditing {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                withAnimation {
                                                    isEditing = true
                                                    selectedItems.insert(item.id)
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                            .animation(.default, value: filteredVocabs)
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, AppPadding.areaPadding)
                .padding(.bottom, AppPadding.areaPadding)
                .safeAreaInset(edge: .top) {
                    Group {
                        if isEditing {
                            // Editing mode: floating glass pills
                            HStack(spacing: 12) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isEditing = false
                                        selectedItems.removeAll()
                                    }
                                }) {
                                    Text("Batal")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(.regularMaterial)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
                                }
                                .buttonStyle(.plain)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                
                                Spacer()
                                
                                Text(selectedItems.isEmpty ? "Pilih item" : "\(selectedItems.count) Terpilih")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: { deleteSelectedItems() }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(selectedItems.isEmpty ? Color.primary.opacity(0.3) : .red)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(.regularMaterial)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
                                }
                                .buttonStyle(.plain)
                                .disabled(selectedItems.isEmpty)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, AppPadding.areaPadding)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            // Normal mode: title left, search glass button right
                            HStack(alignment: .center, spacing: AppSpacing.medium) {
                                if isMagnifying {
                                    AppTextField(text: $typping)
                                } else {
                                    AppHeadline(
                                        title: "Koleksi Kosakata",
                                        subtitle: "Jumlah kosakata yang sudah kamu simpan",
                                        titleStyle: .appHeadlinev2,
                                        subtitleStyle: .appHeadline,
                                        titleColor: .primary,
                                        aligment: .leading,
                                        spacing: AppSpacing.textSpacing
                                    )
                                    .opacity(Double(1.0 + (scrollOffset / 50.0)))
                                    .animation(.linear(duration: 0.1), value: scrollOffset)
                                    
                                    Spacer()
                                }
                                
                                AppToolbar(
                                    onMagnifyingTap: { isClicked in
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            isMagnifying = isClicked
                                            if !isClicked {
                                                typping = ""
                                            }
                                        }
                                    },
                                    horizontalPadding: AppPadding.areaPadding,
                                    verticalPadding: AppPadding.areaPadding
                                )
                            }
                            .padding(.horizontal, AppPadding.areaPadding)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 8)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .mask(
                                LinearGradient(
                                    stops: [
                                        .init(color: .black, location: 0.0),
                                        .init(color: .black.opacity(0.8), location: 0.4),
                                        .init(color: .clear, location: 1.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .ignoresSafeArea(edges: .top)
                            .opacity(min(1.0, max(0.0, -scrollOffset / 15.0)))
                    )
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isEditing)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isMagnifying)
                }
                .onChange(of: typping) { _, newValue in
                    Task {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        if typping == newValue {
                            await MainActor.run {
                                debouncedTypping = newValue
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(item: $selectedVocab) { vocab in
                let sentences = vocab.sentences.map {
                    GeneratedSentence(type: $0.type, text: $0.text, meaning: $0.meaning)
                }
                let dictToInject = vocab.vocabDictionary.isEmpty
                    ? [vocab.textVocab.lowercased(): vocab.textMeaning]
                    : vocab.vocabDictionary
                    
                ResultView(
                    isFromHome: true, // We can reuse this flag or pass false based on needs
                    detectedObjects: [vocab.textVocab],
                    capturedImageData: vocab.imageData,
                    injectedSentences: sentences,
                    injectedVocab: dictToInject
                )
            }
        }
    }
    
    private func deleteSelectedItems() {
        withAnimation {
            for item in savedVocabs where selectedItems.contains(item.id) {
                modelContext.delete(item)
            }
            do {
                try modelContext.save()
            } catch {
            }
            selectedItems.removeAll()
            isEditing = false
        }
    }
}

#Preview {
    HistoryView()
}
