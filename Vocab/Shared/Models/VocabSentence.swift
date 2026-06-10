//
//  VocabSentence.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 10/06/26.
//


struct VocabSentence: Identifiable, Codable {
    var id = UUID()
    var text: String
    var type: AppSentenceType
}
