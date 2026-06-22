//
//  AppSentenceType.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI


enum AppSentenceType: String, Codable, CaseIterable, Identifiable {
    case statement
    case question
    case command
    case exclamation

    var id: Self { self }
    
    var title: String {
        switch self {
            case .statement: return "Pernyataan"
            case .question: return "Pertanyaan"
            case .command: return "Perintah"
            case .exclamation: return "Seruan"
        }
    }

    var sortOrder: Int {
        switch self {
            case .statement: return 0
            case .question: return 1
            case .command: return 2
            case .exclamation: return 3
        }
    }

    var iconName: String {
        switch self {
            case .statement: return "info.bubble.fill"
            case .question: return "questionmark.bubble.fill"
            case .command: return "speaker.wave.2.bubble.fill"
            case .exclamation: return "exclamationmark.bubble.fill"
        }
    }
}
