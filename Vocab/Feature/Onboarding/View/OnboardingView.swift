//
//  OnboardingView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//
import SwiftUI

struct OnboardingView: View{
    var body: some View{
        VStack(){
            AppImage(
                image: AppImageAsset.onboardingImage
            )
            .frame(width : 480 , height: 480 )
            
        
            Spacer()
            
            VStack(spacing: 30){
                AppHeadline(
                    title: "Ambil foto untuk mengetahui kosakata baru!" ,
                    subtitle : "Foto benda di sekitarmu untuk temukan kosakata baru, dan lihat bagaimana cara menggunakannya dalam kalimat!",
                    titleStyle: .appTitle,
                    subtitleStyle: .appHeadline,
                    aligment: .leading,
                    spacing: 12,
                    isFullWidth: true
                )
                
                
                AppButton(
                    textButton: "Mulai",
                    textColor: .white,
                    backgroundColor: Color.brandColorPrimaryTeal,
                    action: {
                        // add your logic on here
                    }
                )
            }
            .padding(AppPadding.areaPadding)
            
        }
      
    }
}


#Preview {
    OnboardingView()
}
