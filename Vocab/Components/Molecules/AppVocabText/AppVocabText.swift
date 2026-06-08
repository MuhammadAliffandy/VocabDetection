//
//  AppVocabText.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI


struct AppVocabText: View {
    
    var vocabText: String
    var meaningText: String
    
    var body: some View {
        AppHeadline(
            title: vocabText ,
            subtitle : meaningText,
            titleStyle: .appLargeTitle,
            titleColor: .white,
            subtitleColor: Color.white.opacity(0.7),
            aligment: .center,
            spacing: 0,
            isFullWidth: false,
        )
       
        .padding(AppPadding.buttonPadding)
        .background(Color.brandColorPrimaryTeal)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.vocabShapeRadius))
        
    }
}


#Preview {
    AppVocabText(
        vocabText: "Chair" ,
        meaningText: "/ˈtʃɛɹ/ : Kursi",
    )
}
