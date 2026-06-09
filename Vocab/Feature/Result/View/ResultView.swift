import SwiftUI

struct ResultView: View {
    
    var isFromHome : Bool? = false
    let rawSentence: String = "rock is very hard"
    let vocabDictionary: [String: String] = [
        "rock": "Batu",
        "hard": "Keras"
    ]
    
    @State private var navigateBackToHome = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
            
                ScrollView {
                    VStack(spacing: 0) {
                        ZStack {
                            AppImage(
                                image: AppImageAsset.dummyImage
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                            
                            AppVocabSpeech(action: {
                                print("test")
                            })
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
                            

                            Spacer()
                                .frame(height: 100)
                        }
                        .padding(.top, 30)
                        .padding(AppPadding.areaPadding)
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                VStack {
                    AppButton(
                        textButton: "Simpan",
                        textColor: Color.white,
                        backgroundColor: Color.brandColorPrimaryTeal,
                        action: {
                            navigateBackToHome = true
                        }
                    )
                    .padding(AppPadding.areaPadding)
                }
                .frame(maxWidth: .infinity)
           
                
         
                ZStack(alignment: .top) {
                    HStack {
                        if isFromHome == false {
                            AppGlassButton(
                                icon: AppIcon.ChevronLeftIcon,
                                text: "Retake",
                                action: { print("Save tapped") }
                            )
                        }
                    
                        Spacer()
                        
                        AppGlassButton(
                            icon: AppIcon.XmarkIcon,
                            action: {
                                navigateBackToHome = true
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
            }
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateBackToHome) {
                HomeView()
            }
        }
    }
}

#Preview {
    ResultView()
}
