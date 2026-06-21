import SwiftUI
import SwiftData
import Translation

@MainActor
struct ResultView: View {
    
    var isFromHome: Bool? = false
    var detectedObjects: [String] = ["rock", "hard"]
    var capturedImageData: Data?
    var injectedSentences: [GeneratedSentence]?
    var injectedVocab: [String: String]?
    var injectedPronunciation: String?


    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = ResultViewModel()
    
    @AppStorage("isCameraPresented") private var isCameraPresented: Bool = true
    @AppStorage("mainSelectedTab") private var mainSelectedTab: Int = 0
    @AppStorage("inDemoFlow") private var inDemoFlow: Bool = false
    @AppStorage("isShowingFlashcardDemo") private var isShowingFlashcardDemo: Bool = false
    @State var isRetake: Bool = false
    @State private var showAppleIntelligenceAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
            
                ScrollView {
                    VStack(spacing: 0) {
                        ZStack {
                            if let data = capturedImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 400)
                                    .clipped()
                                    .ignoresSafeArea()
                            } else {
                                AppImage(
                                    image: AppImageAsset.dummyImage
                                )
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 400)
                                .ignoresSafeArea()
                            }

                            
                            let firstWord = detectedObjects.first ?? "Unknown"
                            let meaning = viewModel.vocabDictionary[firstWord.lowercased()] ?? firstWord
                            let ipa = viewModel.getIPA(for: firstWord)
                            
                            AppVocabSpeech(
                                vocabText: firstWord.capitalized,
                                meaningText: "\(ipa) : \(meaning.capitalized)",
                                action: {
                                    viewModel.speakSentence(text: firstWord)
                                }
                            )
                            .offset(y: 200)
                        }
                        
                        VStack(spacing: AppSpacing.regular) {
                            AppHeadline(
                                title: "Kalimat",
                                subtitle: "Penggunaan kosakata dalam kalimat",
                                titleStyle: .appTitle,
                                subtitleStyle: .appSubheadline,
                                titleColor: .primary,
                                aligment: .leading,
                                spacing: AppSpacing.textSpacing,
                                isFullWidth: true
                            )
                            
                            if viewModel.isLoading {
                                ProgressView("Sedang memproses kalimat...")
                                    .padding(.top, 20)
                            } else {
                                ForEach(viewModel.generatedSentences) { sentence in
                                    AppSentenceAccordion(
                                        rawSentence: sentence.text,
                                        meaningSentence: sentence.meaning,
                                        vocabDictionary: viewModel.vocabDictionary,
                                        selectedType: sentence.type,
                                        isAppleIntelligence: viewModel.isAppleIntelligenceAvailable,
                                        mainVocabWord: detectedObjects.first
                                    )
                                }
                            }
                            

                            Spacer()
                                .frame(height: 100)
                        }
                        .padding(.top, 57)
                        .padding(AppPadding.areaPadding)
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                if isFromHome != nil && isFromHome == false {
                    VStack {
                        AppButton(
                            textButton: "Simpan Kosakata",
                            textColor: Color.white,
                            backgroundColor: Color.brandColorPrimaryTeal,
                            action: {
                                let firstWord = detectedObjects.first ?? "Unknown"
                                let firstWordLower = firstWord.lowercased()
                                
                                let sourceDict = injectedVocab ?? viewModel.vocabDictionary
                                let rawMeaning = sourceDict[firstWordLower] ?? ""
                                let meaning = rawMeaning.isEmpty || rawMeaning.lowercased() == firstWordLower
                                    ? firstWord
                                    : rawMeaning
                                
                                // IPA: dari injectedPronunciation jika ada, fallback PhoneticService
                                let ipa: String
                                if let injected = injectedPronunciation, !injected.isEmpty, injected.lowercased() != firstWordLower {
                                    ipa = "/\(injected.lowercased())/"
                                } else {
                                    ipa = "/\(PhoneticService.phonetic(for: firstWordLower))/"
                                }
                                
                                let sentences = viewModel.generatedSentences.map {
                                    VocabSentence(text: $0.text, meaning: $0.meaning, type: $0.type)
                                }
                                
                                let newItem = VocabItem(
                                    textVocab: firstWord.capitalized,
                                    textMeaning: meaning,
                                    textIPA: ipa,
                                    imageData: capturedImageData,
                                    sentences: sentences,
                                    vocabDictionary: sourceDict
                                )
                                
                                modelContext.insert(newItem)
                                do {
                                    try modelContext.save()
                                } catch {
                                }
                                
                                if inDemoFlow {
                                    isCameraPresented = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                        isShowingFlashcardDemo = true
                                    }
                                } else {
                                    isCameraPresented = false
                                }
                            }
                        )
                        .padding(AppPadding.areaPadding)
                        .AppShadowVocabCard()
                        .accessibilityLabel("Simpan Kosakata")
                        .accessibilityHint("Menyimpan kosakata ini beserta kalimatnya ke beranda")
                    }
                    .frame(maxWidth: .infinity)
                }
           
                
         
                ZStack(alignment: .top) {
                    HStack {
                        if isFromHome == false {
                            AppGlassButton(
                                icon: AppIcon.ChevronLeftIcon,
                                text: "Retake",
                                action: { 
                                   isRetake = true
                                },
                                horizontalPadding: AppPadding.areaPadding ,
                                verticalPadding: AppPadding.areaPadding / 1.5
                            )
                            .accessibilityLabel("Ulangi Foto")
                            .accessibilityHint("Kembali ke kamera untuk mengambil foto ulang")
                    
                        }
                    
                        Spacer()
                        
                        AppGlassButton(
                            icon: AppIcon.XmarkIcon,
                            action: {
                                inDemoFlow = false
                                dismiss()
                                if isFromHome == true {
                                    // Kembali ke Collections tab
                                    mainSelectedTab = 1
                                }
                                isCameraPresented = false
                            },
                            horizontalPadding: AppPadding.areaPadding / 1.5,
                            verticalPadding: AppPadding.areaPadding / 1.5
                        )
                        .accessibilityLabel("Tutup")
                        .accessibilityHint("Tutup halaman ini dan kembali")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                if showAppleIntelligenceAlert {
                    AppleIntelligenceAlert(isShowing: $showAppleIntelligenceAlert)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $isRetake) {
                CameraView()
            }
            .onAppear {
                if let injectedSentences = injectedSentences, let injectedVocab = injectedVocab {
                    viewModel.generatedSentences = injectedSentences
                    viewModel.vocabDictionary = injectedVocab
                } else if viewModel.generatedSentences.isEmpty && !viewModel.isLoading {
                    if #unavailable(iOS 17.4) {
                        Task { await viewModel.processDetectedObjects(detectedObjects) }
                    }
                }
                
                if !viewModel.isAppleIntelligenceAvailable {
                    showAppleIntelligenceAlert = true
                }
            }
            .modifier(TranslationTaskModifier(
                viewModel: viewModel,
                detectedObjects: detectedObjects,
                shouldProcess: injectedSentences == nil && viewModel.generatedSentences.isEmpty
            ))
        }
    }
}

struct TranslationTaskModifier: ViewModifier {
    var viewModel: ResultViewModel
    var detectedObjects: [String]
    var shouldProcess: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 17.4, *) {
            content.translationTask(source: Locale.Language(identifier: "en-US"), target: Locale.Language(identifier: "id")) { session in
                if shouldProcess {
                    viewModel.setTranslationSession(session)
                    await viewModel.processDetectedObjects(detectedObjects)
                }
            }
        } else {
            content
        }
    }
}

#Preview {
    ResultView()
}
