//
//  OnboardingView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//
import SwiftUI

struct OnboardingView: View{
    var body: some View{
        VStack{
            AppImage(
                image: AppImageAsset.onboardingImage
            )
        
            
            AppHeadline(
                title: "Ambil foto untuk mengetahui kosakata baru! " ,
                subtitle : "Foto benda di sekitarmu untuk temukan kosakata baru, dan lihat bagaimana cara menggunakannya dalam kalimat!",
                titleStyle: .appTitle,
                subtitleStyle: .appHeadline,
                aligment: .leading,
                spacing: 12,
         
            )
            
            AppButton(
                textButton: "Text example",
                backgroundColor: Color.brandColorPrimaryTeal,
                action: {
                    // add your logic on here
                }
            )
            
            
        }
    }
}


#Preview {
    OnboardingView()
}
