//
//  Home.swift
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
    @State private var isMagnifying: Bool = false
    @State private var showDropdown: Bool = false
    @State private var selectedVocab: VocabItem?
    @State private var typping: String = ""
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?
    @State private var isEditing: Bool = false
    @State private var selectedItems: Set<VocabItem.ID> = []

    enum DashboardFilterType {
        case total
        case today
    }
    
    @State private var dashboardFilter: DashboardFilterType = .total

    var filteredVocabs: [VocabItem] {
        let baseList: [VocabItem]
        if dashboardFilter == .today {
            let calendar = Calendar.current
            baseList = savedVocabs.filter { calendar.isDateInToday($0.createDate) }
        } else {
            baseList = savedVocabs
        }
        
        if typping.isEmpty {
            return baseList
        } else {
            return baseList.filter { item in
                item.textVocab.lowercased().contains(typping.lowercased()) ||
                item.textMeaning.lowercased().contains(typping.lowercased())
            }
        }
    }

    var todayVocabCount: Int {
        let calendar = Calendar.current
        return savedVocabs.filter { calendar.isDateInToday($0.createDate) }.count
    }

    let gridColumns = [
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: AppSpacing.medium) {
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
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            .transition(.opacity)
                        } else {
                            HStack(alignment: .top, spacing: AppSpacing.medium) {
                                if !isMagnifying {
                                    AppHeadline(
                                        title: "Kosakata Kamu",
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
                        
                        if !isMagnifying {
                            HStack(spacing: AppSpacing.medium) {
                                AppVocabDashboardCard(
                                    icon: AppIcon.BookPagesIcon,
                                    title: "Total",
                                    subtitle: "Kosakata",
                                    count: "\(savedVocabs.count)"
                                )
                                .onTapGesture {
                                    withAnimation {
                                        dashboardFilter = .total
                                    }
                                }
                                
                                AppVocabDashboardCard(
                                    icon: AppIcon.ClockBadgeCheckmarkIcon,
                                    title: "Kosakata",
                                    subtitle: "Hari ini",
                                    count: "\(todayVocabCount)"
                                )
                                .onTapGesture {
                                    withAnimation {
                                        dashboardFilter = .today
                                    }
                                }
                            }
                        }

                        if savedVocabs.isEmpty {
                            Spacer()
                                .frame(height: 100)
                            
                            AppHeadline(
                                title: "Belum ada Kosakata",
                                subtitle: "Silahkan ambil gambar dengan kamera atau galeri untuk menemukan kosakata baru.",
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
                            VStack(alignment: .leading){
                                AppText(
                                    text: isMagnifying && !typping.isEmpty ? "Hasil Pencarian"
                                    : (dashboardFilter == .today ? "Hari Ini" : "Terbaru"),
                                    fontStyle: .appHeadlinev2,
                                    textColor: .primary
                                )
                            }
                            
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
                                                selectedVocab = item
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
                .padding(AppPadding.areaPadding)
                .background(Color(UIColor.systemGroupedBackground))
                .disabled(isDemo)
                
                if isDemo {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)
                }
                
                VStack {
                    Spacer()
                    
                    AppCameraButton(action: {
                        withAnimation {
                            showDemo = false
                        }
                        isShowingCamera = true
                    })
                    .appTooltip("Ketuk di sini untuk\nmembuka kamera dan\nmulai memfoto benda\ndisekitarmu",
                        isVisible: isDemo ? true : false)
                }
                .padding(AppPadding.areaPadding)
                
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraView()
                    .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden(true)
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
    HomeView()
}
