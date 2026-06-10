////
////  DemoView.swift
////  Vocab
////
////  Created by Muhammad Aliffandy on 06/06/26.
////
//import SwiftUI
//
//struct DemoView: View {
//    
//    @State private var navigateToHome = false
//    @State private var isDemo = false
//
//    var body: some View {
//        NavigationStack{
//            ZStack(alignment: .top) {
//                VStack {
//                    AppImage(
//                        image: AppImageAsset.demoImage
//                    )
//                    .frame(maxWidth: .infinity)
//                    .frame(maxHeight: 400)
//                    
//                    Spacer()
//                    
//                    AppHeadline(
//                        title: "Kami siapkan demo ini untuk memperlihatkan cara kerja aplikasi kami",
//                        subtitle: "coba lakukan demo untuk melihat bagaimana aplikasi ini membantumu belajar kosakata baru dari benda sekitarmu!",
//                        titleStyle: .appTitle,
//                        subtitleStyle: .appHeadline,
//                        titleColor: .primary,
//                        aligment: .leading,
//                        spacing: AppSpacing.regular,
//                        isFullWidth: true
//                    )
//
//                    Spacer()
//                    
//                    AppButton(
//                        textButton: "Coba Demo",
//                        textColor: .white,
//                        backgroundColor: Color.teal,
//                        action: {
//                            navigateToHome = true
//                            isDemo = true
//                        }
//                    )
//                }
//                .padding(AppPadding.areaPadding)
//                
//                HStack {
//                    Spacer()
//                    
//                    AppGlassButton(
//                        icon: "xmark",
//                        action: {
//                            
//                        }
//                    )
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//                
//            }
//            .navigationBarBackButtonHidden(true)
//            .navigationDestination(isPresented: $navigateToHome){
//                isDemo ? HomeView(isDemo: true) : HomeView()
//            }
//        }
//    }
//    
//}
//
//
//#Preview {
//    DemoView()
//      
//}
