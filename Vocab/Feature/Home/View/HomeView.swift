//
//  Home.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI


struct HomeView:View {
    
    @State private var typping: String = ""
    
    var body: some View {
        VStack(spacing: 10 ){
            AppTextField(text: $typping)
            AppHeadline(
                title: "Terbaru" ,
                subtitle : "Foto terbaru yang anda tambahkan",
                titleStyle: .appHeadlinev2,
                subtitleStyle: .appHeadline,
                aligment: .leading,
                spacing: 12,
            )
        }
        .padding(AppPadding.areaPadding)
    }
}


#Preview {
    HomeView()
}
