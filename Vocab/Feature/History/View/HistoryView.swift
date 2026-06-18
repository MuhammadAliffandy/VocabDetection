//
//  HistoryView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VocabItem.createDate, order: .reverse) private var savedVocabs: [VocabItem]
    
    @State private var isMagnifying: Bool = false
    @State private var typping: String = ""
    @State private var debouncedTypping: String = ""
    @State private var isEditing: Bool = false
    @State private var selectedItems: Set<VocabItem.ID> = []
    @State private var selectedVocab: VocabItem?
    
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
                    VStack(spacing: AppSpacing.medium) {
                        Color.clear.frame(height: 12)
                        
                        if isEditing {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        isEditing = false
                                        selectedItems.removeAll()
                                    }
                                }) {
                                    Text("Batal")
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.brandColorPrimaryTeal)
                                }
                                .accessibilityLabel("Batal edit")
                                .accessibilityHint("Batalkan mode hapus kosakata")
                                
                                Spacer()
                                
                                Text("\(selectedItems.count) Terpilih")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: {
                                    deleteSelectedItems()
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 20))
                                        .foregroundColor(selectedItems.isEmpty ? .gray : .red)
                                }
                                .disabled(selectedItems.isEmpty)
                                .accessibilityLabel("Hapus kosakata terpilih")
                                .accessibilityHint("Hapus kosakata yang sudah dipilih")
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            .transition(.opacity)
                        } else {
                            HStack(alignment: .top, spacing: AppSpacing.medium) {
                                if !isMagnifying {
                                    AppHeadline(
                                        title: "Koleksi Kosakata",
                                        subtitle: "Jumlah kosakata yang sudah kamu simpan",
                                        titleStyle: .appHeadlinev2,
                                        subtitleStyle: .appHeadline,
                                        titleColor: .primary,
                                        aligment: .leading,
                                        spacing: AppSpacing.textSpacing
                                    )
                                } else {
                                    AppTextField(text: $typping)
                                }
                                
                                AppToolbar(
                                    onMagnifyingTap: { isClicked in
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            isMagnifying = isClicked
                                        }
                                    },
                                    horizontalPadding: AppPadding.areaPadding
                                )
                            }
                            .transition(.opacity)
                        }
                        
                        if savedVocabs.isEmpty {
                            Spacer()
                                .frame(height: 100)
                            
                            AppHeadline(
                                title: "Belum ada Kosakata",
                                subtitle: "Kosakata yang kamu ambil akan tersimpan di sini.",
                                titleStyle: .appHeadlinev2,
                                subtitleStyle: .appHeadline,
                                titleColor: .primary,
                                aligment: .center,
                                spacing: AppSpacing.textSpacing,
                                textAlign: .center
                            )
                            .padding(.horizontal, 20)
                            
                        } else if filteredVocabs.isEmpty {
                            Spacer()
                                .frame(height: 100)
                                
                            AppText(
                                text: "Belum ada kosakata tersimpan\ndengan nama ini",
                                fontStyle: .appSubheadline,
                                textColor: .textColorSecondaryBlackGrey
                            )
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                            
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
                .scrollIndicators(.hidden)
                .padding(.horizontal, AppPadding.areaPadding)
                .padding(.bottom, AppPadding.areaPadding)
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
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 47)
                    .ignoresSafeArea(edges: .top)
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
                print("Failed to save after deletion: \(error)")
            }
            selectedItems.removeAll()
            isEditing = false
        }
    }
}

#Preview {
    HistoryView()
}
