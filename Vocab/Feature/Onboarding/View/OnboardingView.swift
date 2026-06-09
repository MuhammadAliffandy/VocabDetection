//
//  OnboardingView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//
import SwiftUI

struct OnboardingView: View{
    
    @State private var navigateToDemo = false
    
    var body: some View{
        NavigationStack{
            VStack(){
                AppImage(
                    image: AppImageAsset.onboardingImage
                )
                .frame(maxWidth: .infinity)
                .frame( height: 500 )
                
            
                Spacer()
                
                VStack(spacing: 30){
                    AppHeadline(
                        title: "Ambil foto untuk mengetahui kosakata baru!" ,
                        subtitle : "Foto benda di sekitarmu untuk temukan kosakata baru, dan lihat bagaimana cara menggunakannya dalam kalimat!",
                        titleStyle: .appTitle,
                        subtitleStyle: .appHeadline,
                        titleColor: .primary,
                        aligment: .leading,
                        spacing: AppSpacing.regular,
                        isFullWidth: true
                    )
                    
                    
                    AppButton(
                        textButton: "Mulai",
                        textColor: .white,
                        backgroundColor: Color.brandColorPrimaryTeal,
                        action: {
                           navigateToDemo = true
                        }
                    )
                }
                .padding(AppPadding.areaPadding)
                
            }
            .navigationDestination(isPresented: $navigateToDemo){
                DemoView()
            }
        }
   
      
    }
}


#Preview {
    OnboardingView()
     
}
