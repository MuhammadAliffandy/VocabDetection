import SwiftUI
import Translation

struct ResultLoadingView: View {
    var imageData: Data?
    var labels: [String] = []
    
    @StateObject private var viewModel = ResultViewModel()
    @State private var navigateToResult = false
    @State private var translationStatus: String = "Memindai kosa kata..."
    @State private var translationSubtitle: String = "Memindai kata dari gambar yang sudah kamu ambil"
    @State private var isDownloadingLanguage: Bool = false
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
            checkTranslationAvailability()
            if #unavailable(iOS 17.4) {
                Task {
                    await viewModel.processDetectedObjects(labels)
                }
            }
        }
        .modifier(TranslationTaskModifier(
            viewModel: viewModel,
            detectedObjects: labels,
            shouldProcess: true
        ))
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
                detectedObjects: labels,
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
                    // Sudah tersedia, proses normal
                    isDownloadingLanguage = false
                    translationStatus = "Memindai kosa kata..."
                    translationSubtitle = "Memindai kata dari gambar yang sudah kamu ambil"
                    
                case .supported:
                    // Didukung tapi belum diunduh — .translationTask akan otomatis trigger download sheet
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
}

#Preview {
    NavigationStack {
        ResultLoadingView()
    }
}
