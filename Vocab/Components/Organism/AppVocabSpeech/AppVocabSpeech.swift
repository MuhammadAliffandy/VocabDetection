//
//  AppVocabSpeech.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppVocabSpeech: View {
    
    var action: () -> Void
    
    var body: some View {
        AppWrapButton(action: action ){
            ZStack(alignment: .bottom){
                AppVocabText(
                    vocabText: "Chair" ,
                    meaningText: "/ˈtʃɛɹ/ : Kursi",
                )
                AppIconSpeech()
                .offset(y: 20)
            }
        }
    }
}


#Preview {
    AppVocabSpeech(
        action: {}
    )
}
