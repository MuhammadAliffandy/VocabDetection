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
                // LAYER 1: Unified White Outline
                ZStack(alignment: .bottom) {
                    AppVocabText(vocabText: formattedVocabText, meaningText: meaningText)
                        .opacity(0)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.vocabShapeRadius + 6)
                                .fill(Color.white)
                                .padding(-6)
                        )
                    
                    AppIconSpeech()
                        .opacity(0)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .padding(-6)
                        )
                        .offset(y: 20)
                }
                
                // LAYER 2: Unified Teal Foreground
                ZStack(alignment: .bottom) {
                    AppVocabText(
                        vocabText: formattedVocabText ,
                        meaningText: meaningText
                    )
                    
                    AppIconSpeech()
                        .offset(y: 20)
                }
            }
            .padding(.bottom, 20) // make room for the overflowing icon
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
