//
//  AppSentenceContent.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct WordItem: Identifiable {
    let id = UUID()
    let text: String
}

struct AppSentenceContent: View {

    let rawSentence: String
    let vocabDictionary: [String: String]
    let textStyle: Font = .appHeadline
    
    @State private var activeWordID: UUID? = nil
    
    let splittedWords: [WordItem]
    
    init(rawSentence: String,
         vocabDictionary: [String: String],
         textStyle: Font
    ) {
        self.rawSentence = rawSentence
        self.vocabDictionary = vocabDictionary
    
        self.splittedWords = rawSentence.split(separator: " ").map { WordItem(text: String($0)) }
    }
    
    var body: some View {
        
        // Replace HStack with our new custom FlowLayout
        AppFlowLayout(spacing: 6) {
            
            ForEach(splittedWords) { item in
                let cleanWord = item.text.trimmingCharacters(in: .punctuationCharacters).lowercased()
                
                if let meaning = vocabDictionary[cleanWord] {
                    AppWordTip(
                        text: item.text,
                        tooltipText: meaning,
                        textStyle: textStyle,
                        isPressed: activeWordID == item.id,
                        isVocab: true
                    )
                    .zIndex(activeWordID == item.id ? 1 : 0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if activeWordID == item.id {
                                activeWordID = nil
                            } else {
                                activeWordID = item.id
                            }
                        }
                    }
                    
                } else {
                    AppWordTip(
                        text: item.text,
                        tooltipText: "",
                        textStyle: textStyle,
                        isPressed: false,
                        isVocab: false
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            activeWordID = nil
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {
     
        AppSentenceContent(
            rawSentence: "rock is very hard even you needed ",
            vocabDictionary: [
                "rock": "Batu",
                "hard": "Keras"
            ],
            textStyle: .appHeadline
            
        )
    }
    .padding(100)
    .background(Color.red)
}
