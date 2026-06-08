//
//  Home.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI


struct HomeView:View {
    
    @State private var previewPeriod = "Tanggal"
    @State private var isNewest: Bool = true
    @State private var isMagnifying: Bool = false
    @State private var showDropdown: Bool = false
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
                    
                    VStack(spacing: 16 ){
                        HStack(
                            alignment: .top, 
                            spacing: 16){
                            
                            if !isMagnifying {
                                AppHeadline(
                                    title: "Kosakata Kamu" ,
                                    subtitle : "Jumlah kosakata yang sudah kamu ketahui",
                                    titleStyle: .appHeadlinev2,
                                    subtitleStyle: .appHeadline,
                                    aligment: .leading,
                                    spacing:AppSpacing.textSpacing,
                                )
                            }else{
                                AppTextField(text: $typping)
                            }
                            
                            AppToolbar(
                                onMagnifyingTap: {
                                    isClicked in
                                    isMagnifying = isClicked
                                }, onEllipsisTap: {
                                    showDropdown.toggle()
                                },
                                onDateTap: {
                                    isNewest = false
                                },
                                onNewestTap: {
                                    isNewest = true
                                },
                            )
                                
                            
                                
                        }
                        
                        if !isMagnifying {
                            
                            HStack(spacing: 16){
                                AppVocabDashboardCard(
                                    icon:AppIcon.BookPagesIcon,
                                    title: "Total",
                                    subtitle: "Kosakata",
                                    count: "0"
                                )
                                
                                AppVocabDashboardCard(
                                    icon:AppIcon.ClockBadgeCheckmarkIcon,
                                    title: "Kosakata",
                                    subtitle: "Hari ini",
                                    count: "0"
                                )
                            }
                            
                        }

                        if isNewest {
                            AppHeadline(
                                title: "Terbaru" ,
                                subtitle : "Foto terbaru yang anda tambahkan",
                                titleStyle: .appHeadlinev2,
                                subtitleStyle: .appHeadline,
                                aligment: .leading,
                                spacing:AppSpacing.textSpacing,
                            )
                        }
                        else{
                            HStack(spacing: 16){
                                
                                AppText(
                                    text: "8 Juni",
                                    fontStyle: .appHeadlinev2
                                    
                                )
                                
                                Spacer()
                                
                                AppOptionPicker(selectedPeriod: $previewPeriod
                                ,options:  ["Tanggal", "Bulan", "Tahun"]
                                )
                                
                            }
                        }
                        
                       
                        
                        
                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            
                            AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Chair",
                                subtitle: "Kursi",
                                onTapGesture: {
                                    navigateToResultLoading = true
//                                    print("appvocabCard")
                                }
                            )
                             AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Chair",
                                subtitle: "Kursi",
                                onTapGesture: {
                                    print("test")
                                }
                            )
                             AppVocabCard(
                                image: AppImageAsset.dummyImage,
                                title: "Chair",
                                subtitle: "Kursi",
                                onTapGesture: {
                                    print("test")
                                }
                            )
                            
                        }
                        
                        
                    }
                }
                .scrollIndicators(.hidden)
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
