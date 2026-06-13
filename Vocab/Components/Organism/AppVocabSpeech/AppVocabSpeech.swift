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
    
    var formattedVocabText: String {
        let words = vocabText.split(separator: " ")
        return words.joined(separator: "\n")
    }
    
    var body: some View {
        AppWrapButton(action: action ){
            ZStack(alignment: .bottom){
                AppVocabText(
                    vocabText: formattedVocabText ,
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
        vocabText: "headman Chair",
        meaningText: "/ˈtʃɛɹ/ : Kursi",
        action: {}
    )
}
