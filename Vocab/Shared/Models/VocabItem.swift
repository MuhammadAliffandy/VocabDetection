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

    /// Disimpan sebagai JSON string karena SwiftData tidak support Dictionary secara native
    private var vocabDictionaryData: String = "{}"

    /// Accessor untuk vocabDictionary — encode/decode dari JSON string
    var vocabDictionary: [String: String] {
        get {
            guard let data = vocabDictionaryData.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let jsonString = String(data: data, encoding: .utf8) {
                vocabDictionaryData = jsonString
            }
        }
    }

    init(
        textVocab: String,
        textMeaning: String,
        textIPA: String = "",
        imageData: Data? = nil,
        sentences: [VocabSentence] = [],
        createDate: Date = Date(),
        vocabDictionary: [String: String] = [:]
    ) {
        self.textVocab = textVocab
        self.textMeaning = textMeaning
        self.textIPA = textIPA
        self.imageData = imageData
        self.sentences = sentences
        self.createDate = createDate
        // Encode dictionary saat init
        if let data = try? JSONEncoder().encode(vocabDictionary),
           let jsonString = String(data: data, encoding: .utf8) {
            self.vocabDictionaryData = jsonString
        }
    }
}
