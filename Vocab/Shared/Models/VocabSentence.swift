//
//  VocabSentence.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 10/06/26.
//


import SwiftData
import Foundation

@Model
class VocabSentence: Identifiable {
    var id: UUID = UUID()
    var text: String
    var meaning: String
    var type: AppSentenceType
    
    // Inverse relationship (Optional)
    var vocabItem: VocabItem?
    
    init(text: String, meaning: String, type: AppSentenceType) {
        self.text = text
        self.meaning = meaning
        self.type = type
    }
}
