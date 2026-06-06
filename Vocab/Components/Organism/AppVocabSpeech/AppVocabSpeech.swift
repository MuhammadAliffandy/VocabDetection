//
//  AppVocabSpeech.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppVocabSpeech: View {
    var body: some View {
        ZStack(alignment: .bottom){
            AppVocabText(
                vocabText: "Chair" ,
                meaningText: "/ˈtʃɛɹ/ : Kursi",
            )
            AppIconSpeech(action: {
                
            })
            .offset(y: 20)
        }
    }
}


#Preview {
    AppVocabSpeech()
}
