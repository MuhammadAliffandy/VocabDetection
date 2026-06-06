//
//  DemoView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//
import SwiftUI

struct DemoView: View {
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack {
                AppImage(
                    image: AppImageAsset.demoImage
                )
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 400)
                
                Spacer()
                
                AppHeadline(
                    title: "Kami siapkan demo ini untuk memperlihatkan cara kerja aplikasi kami",
                    subtitle: "coba lakukan demo untuk melihat bagaimana aplikasi ini membantumu belajar kosakata baru dari benda sekitarmu!",
                    titleStyle: .appTitle,
                    subtitleStyle: .appHeadline,
                    aligment: .leading,
                    spacing: 12,
                    isFullWidth: true
                )

                Spacer()
                
                AppButton(
                    textButton: "Coba Demo",
                    textColor: .white,
                    backgroundColor: Color.teal,
                    action: {
                        print("Start Demo")
                    }
                )
            }
            .padding(AppPadding.areaPadding)
            
            HStack {
                Spacer()
                
                AppGlassButton(
                    icon: "xmark",
                    action: { print("Back tapped") }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
        }
    }
}


#Preview {
    DemoView()
}
