//
//  VocabCard.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 10/06/26.
//

import SwiftData
import Foundation

@Model
class VocabItem: Identifiable {
    var id: UUID = UUID()
    var textVocab: String
    var textMeaning: String
    var textIPA: String
    @Attribute(.externalStorage) var imageData: Data?
    @Relationship(deleteRule: .cascade) var sentences: [VocabSentence]
    var createDate: Date
    
    init(textVocab: String, textMeaning: String, textIPA: String = "", imageData: Data? = nil, sentences: [VocabSentence] = [], createDate: Date = Date()) {
        self.textVocab = textVocab
        self.textMeaning = textMeaning
        self.textIPA = textIPA
        self.imageData = imageData
        self.sentences = sentences
        self.createDate = createDate
    }
}
