//
//  Home.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct HomeView: View {
    
    var isDemo: Bool = false
    
    @State private var previewPeriod = "Tanggal"
    @State private var isMagnifying: Bool = false
    @State private var showDropdown: Bool = false
    @State private var navigateToResult = false
    @State private var typping: String = ""
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?

    let gridColumns = [
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: AppSpacing.medium) {
                        HStack(alignment: .top, spacing: AppSpacing.medium) {
                            if !isMagnifying {
                                AppHeadline(
                                    title: "Kosakata Kamu",
                                    subtitle: "Jumlah kosakata yang sudah kamu ketahui",
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
                                    isMagnifying = isClicked
                           
                                },
                                horizontalPadding: AppPadding.areaPadding
                            )
                        }
                        
                        if !isMagnifying {
                            HStack(spacing: AppSpacing.medium) {
                                AppVocabDashboardCard(
                                    icon: AppIcon.BookPagesIcon,
                                    title: "Total",
                                    subtitle: "Kosakata",
                                    count: "0"
                                )
                                
                                AppVocabDashboardCard(
                                    icon: AppIcon.ClockBadgeCheckmarkIcon,
                                    title: "Kosakata",
                                    subtitle: "Hari ini",
                                    count: "0"
                                )
                            }
                        }

                        AppHeadline(
                            title: "Terbaru",
                            subtitle: "Foto terbaru yang anda tambahkan",
                            titleStyle: .appHeadlinev2,
                            subtitleStyle: .appHeadline,
                            titleColor: .primary,
                            aligment: .leading,
                            spacing: AppSpacing.textSpacing
                        )
                        
                        LazyVGrid(columns: gridColumns, spacing: AppSpacing.medium) {
                            ForEach(1..<10, id: \.self) { index in
                                AppVocabCard(
                                    image: AppImageAsset.dummyImage,
                                    title: "Chair",
                                    subtitle: "Kursi",
                                    onTapGesture: {
                                        navigateToResult = true
                                    }
                                )
                            }
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
                        isShowingCamera = true
                    })
                    .appTooltip("Tekan Icon\nuntuk membuka\nkamera", isVisible: isDemo ? true : false)
                }
                
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraView()
                    .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToResult) {
                ResultView(isFromHome: true)
            }
        }
    }
}

#Preview {
    HomeView()
}
