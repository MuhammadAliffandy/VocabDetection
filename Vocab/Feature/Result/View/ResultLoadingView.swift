import SwiftUI
import Translation

struct ResultLoadingView: View {
    var imageData: Data?
    var labels: [String] = []
    
    @StateObject private var viewModel = ResultViewModel()
    // Use @State (value) wrapper — FastVLMService is @Observable, keep reference stable via class box
    @State private var fastVLMService = FastVLMService()
    
    @State private var navigateToResult = false
    @State private var translationStatus: String = "Memindai kosa kata..."
    @State private var translationSubtitle: String = "Menganalisis gambar untuk menemukan objek..."
    @State private var isDownloadingLanguage: Bool = false
    
    @State private var vlmLabels: [String] = []
    @State private var isVLMDone: Bool = false
    @State private var taskIsRunning: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Group {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                        .blur(radius: 6)
                        .ignoresSafeArea(.all)
                } else {
                    Image(AppImageAsset.dummyImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .blur(radius: 6)
                        .ignoresSafeArea(.all)
                }
            }
            
            VStack {
                Spacer()
                
                if isDownloadingLanguage {
                    // Tampilan khusus saat language pack sedang diunduh
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .symbolEffect(.pulse)
                        
                        Text("Mengunduh paket bahasa...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 20)
                } else {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.large)
                }
                
                Spacer()
                
                AppHeadline(
                    title: translationStatus,
                    subtitle: translationSubtitle,
                    titleStyle: .appTitle,
                    subtitleStyle: .appHeadline,
                    titleColor: .primary,
                    aligment: .leading,
                    isFullWidth: true
                )
                .padding(.bottom, 40)
                .padding(.top, AppPadding.areaPadding)
                .padding(.horizontal, AppPadding.areaPadding)
                .adaptiveBackground()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            guard !taskIsRunning else { return }
            taskIsRunning = true
            Task {
                await runFastVLM()
            }
        }
        .onDisappear {
            // Safety net: free any lingering GPU memory when leaving this screen
            fastVLMService.unload()
        }
        .background {
            if #available(iOS 17.4, *) {
                Color.clear
                    .translationTask(source: Locale.Language(identifier: "en-US"), target: Locale.Language(identifier: "id-ID")) { session in
                        viewModel.setTranslationSession(session)
                    }
            }
        }
        .onChange(of: viewModel.isLoading) { _, loading in
            if !loading && !viewModel.generatedSentences.isEmpty {
                // Reset status setelah selesai
                isDownloadingLanguage = false
                navigateToResult = true
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView(
                isFromHome: false,
                detectedObjects: vlmLabels,
                capturedImageData: imageData,
                injectedSentences: viewModel.generatedSentences,
                injectedVocab: viewModel.vocabDictionary,
                injectedPronunciation: viewModel.dynamicPronunciation
            )
        }
    }
    
    private func checkTranslationAvailability() {
        guard #available(iOS 17.4, *) else { return }
        Task {
            let availability = LanguageAvailability()
            let status = await availability.status(
                from: Locale.Language(identifier: "en-US"),
                to: Locale.Language(identifier: "id-ID")
            )
            await MainActor.run {
                switch status {
                case .installed:
                    isDownloadingLanguage = false
                    translationStatus = "Memindai kosa kata..."
                    translationSubtitle = "Memindai kata dari gambar yang sudah kamu ambil"
                    
                case .supported:
                    isDownloadingLanguage = true
                    translationStatus = "Mengunduh paket terjemahan"
                    translationSubtitle = "Paket bahasa Indonesia sedang diunduh. Harap tunggu sebentar..."
                    
                case .unsupported:
                    isDownloadingLanguage = false
                    translationStatus = "Terjemahan tidak tersedia"
                    translationSubtitle = "Perangkat ini tidak mendukung terjemahan Bahasa Inggris → Indonesia"
                    
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func runFastVLM() async {
        // --- Path A: no image, use fallback labels ---
        guard let data = imageData else {
            let labels = self.labels.isEmpty ? ["Unknown"] : self.labels
            await MainActor.run {
                self.vlmLabels = labels
                self.isVLMDone = true
                self.checkTranslationAvailability()
            }
            await self.viewModel.processDetectedObjects(vlmLabels)
            return
        }
        
        // --- Path B: decode image in autoreleasepool to limit peak memory ---
        let uiImage: UIImage? = autoreleasepool {
            UIImage(data: data)
        }
        guard let uiImage else {
            let labels = self.labels.isEmpty ? ["Unknown"] : self.labels
            await MainActor.run {
                self.vlmLabels = labels
                self.isVLMDone = true
                self.checkTranslationAvailability()
            }
            await self.viewModel.processDetectedObjects(vlmLabels)
            return
        }
        
        await fastVLMService.ensureLoaded()
        
        await MainActor.run {
            translationStatus = "Memindai kosa kata..."
            translationSubtitle = "Sedang memproses gambar Anda..."
        }
        
        do {
            // Run inference — UIImage is released immediately after this scope
            let result = try await fastVLMService.detectScene(in: uiImage)
            
            // ✅ Free model + GPU memory BEFORE navigating to result
            fastVLMService.unload()
            
            let detectedLabels = [result.object]
            await MainActor.run {
                self.vlmLabels = detectedLabels
                self.isVLMDone = true
                self.checkTranslationAvailability()
            }
            // processDetectedObjects is async — call it directly (no nested Task)
            await self.viewModel.processDetectedObjects(detectedLabels)
        } catch {
            // ✅ Free model + GPU even on error
            fastVLMService.unload()
            
            let fallback = self.labels.isEmpty ? ["Unknown"] : self.labels
            await MainActor.run {
                self.vlmLabels = fallback
                self.isVLMDone = true
                self.checkTranslationAvailability()
            }
            await self.viewModel.processDetectedObjects(fallback)
        }
    }
}

#Preview {
    NavigationStack {
        ResultLoadingView()
    }
}
