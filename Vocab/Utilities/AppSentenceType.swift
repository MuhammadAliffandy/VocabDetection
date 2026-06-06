//
//  AppSentenceType.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI


enum AppSentenceType: CaseIterable, Identifiable {
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

    var iconName: String {
        switch self {
        case .statement: return "info.bubble.fill"
        case .question: return "questionmark.bubble.fill"
        case .command: return "speaker.wave.2.bubble.fill"
        case .exclamation: return "exclamationmark.bubble.fill"
        }
    }
}
