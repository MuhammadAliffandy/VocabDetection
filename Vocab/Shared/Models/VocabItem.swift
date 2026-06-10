//
//  VocabCard.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 10/06/26.
//

struct VocabItem: Identifiable, Codable {
    let id: UUID
    let textVocab: String
    let textMeaning: String
    let imageData: Data
    let sentences: []
    let createDate: Date
}
