//
//  Home.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI


struct HomeView:View {
    @State private var navigateToResultLoading = false
    @State private var typping: String = ""
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?

    let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        
        NavigationStack{
            ZStack{
                ScrollView{
                    
                    VStack(spacing: 15 ){
                        AppTextField(text: $typping)
                        AppHeadline(
                            title: "Terbaru" ,
                            subtitle : "Foto terbaru yang anda tambahkan",
                            titleStyle: .appHeadlinev2,
                            subtitleStyle: .appHeadline,
                            aligment: .leading,
                            spacing: 10,
                        )
                        
                        
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            
                            AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Orang",
                                onTapGesture: {
                                    navigateToResultLoading = true
                                }
                            )
                            
                            
                            AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Rumah"
                            )
                            
                            AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Mobil"
                            )
                            
                            AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Pohon"
                            )
                            AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Pohon"
                            )
                            
                            AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Pohon"
                            )
                            
                        }
                        
                        
                    }
                }
                .padding(AppPadding.areaPadding)
                .background(Color(UIColor.systemGroupedBackground))
                
                
                VStack{
                    Spacer()
                    
                    AppCameraButton(action : {
                        isShowingCamera = true
                    })
                    .appTooltip(
                        "Tekan Icon\nuntuk membuka\nkamera", isVisible: false)
                }
                
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                AppCameraPicker(selectedImage: $capturedImage)
                    .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToResultLoading ){
                ResultLoadingView()
            }
        }

    }

}


#Preview {
    HomeView()
      
}
