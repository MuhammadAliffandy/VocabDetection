//
//  DemoView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//
import SwiftUI

struct DemoView: View{
    var body: some View{
        VStack(){
            AppImage(
                image: AppImageAsset.demoImage
            )
            .frame(width : 480 , height: 480 )
            
        
            Spacer()
            
            AppHeadline(
                title: "Kami siapkan demo ini untuk memperlihatkan cara kerja aplikasi kami" ,
                subtitle : "coba lakukan demo untuk melihat bagaimana aplikasi ini membantumu belajar kosakata baru dari benda sekitarmu!",
                titleStyle: .appTitle,
                subtitleStyle: .appHeadline,
                aligment: .leading,
                spacing: 12,
            )

            Spacer()
            
            AppButton(
                textButton: "Coba Demo",
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


#Preview {
    DemoView()
}
