//
//  AppVocabSpeech.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppVocabSpeech: View {
    
    var vocabText: String = "Chair"
    var meaningText: String = "/ˈtʃɛɹ/ : Kursi"
    var action: () -> Void 
    
    var body: some View {
        AppWrapButton(action: action ){
            ZStack(alignment: .bottom){
                AppVocabText(
                    vocabText: vocabText ,
                    meaningText: meaningText,
                )
                AppIconSpeech()
                .offset(y: 20)
            }
        }
    }
}


#Preview {
    AppVocabSpeech(
        vocabText: "Chair",
        meaningText: "/ˈtʃɛɹ/ : Kursi",
        action: {}
    )
}
