import SwiftUI
import Translation

struct ResultLoadingView: View {
    var imageData: Data?
    var labels: [String] = []
    
    @StateObject private var viewModel = ResultViewModel()
    
    @State private var navigateToResult = false
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
                
                if viewModel.isDownloadingLanguage {
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
                    title: viewModel.translationStatus,
                    subtitle: viewModel.translationSubtitle,
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
            Task {
                await viewModel.startProcessing(imageData: imageData, fallbackLabels: labels)
            }
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
                navigateToResult = true
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView(
                isFromHome: false,
                detectedObjects: viewModel.vlmLabels,
                capturedImageData: imageData,
                injectedSentences: viewModel.generatedSentences,
                injectedVocab: viewModel.vocabDictionary,
                injectedPronunciation: viewModel.dynamicPronunciation
            )
        }
    }
}

#Preview {
    NavigationStack {
        ResultLoadingView()
    }
}
