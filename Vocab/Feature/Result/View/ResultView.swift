import SwiftUI

struct ResultView: View {
    
    let rawSentence: String = "rock is very hard"
    let vocabDictionary: [String: String] = [
        "rock": "Batu",
        "hard": "Keras"
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    ZStack {
                        AppImage(
                            image: AppImageAsset.dummyImage
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                        
                        AppVocabSpeech()
                            .onTapGesture {
                                print("test")
                            }
                            .offset(y: 170)
                    }
                    
                    VStack(spacing: AppSpacing.regular) {
                        AppHeadline(
                            title: "Memindai kosa kata...",
                            subtitle: "Memindai kata dari gambar yang sudah kamu ambil",
                            titleStyle: .appHeadlinev2,
                            subtitleStyle: .appSubheadline,
                            aligment: .leading,
                            isFullWidth: true
                        )
                        
                        AppSentenceAccordion(rawSentence: rawSentence, vocabDictionary: vocabDictionary, selectedType: .question)
                        AppSentenceAccordion(rawSentence: rawSentence, vocabDictionary: vocabDictionary, selectedType: .exclamation)
                        AppSentenceAccordion(rawSentence: rawSentence, vocabDictionary: vocabDictionary, selectedType: .command)
                        AppSentenceAccordion(rawSentence: rawSentence, vocabDictionary: vocabDictionary, selectedType: .statement)
                    }
                    .padding(.top, 30)
                    .padding(AppPadding.areaPadding)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            HStack {
             
                AppGlassButton(
                    icon: AppIcon.ChevronLeftIcon,
                    text: "Back",
                    action: { print("Save tapped") }
                )
                Spacer()
                
                AppGlassButton(
                    icon: AppIcon.XmarkIcon,
                    action: { print("Back tapped") }
                )
               
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ResultView()
}
