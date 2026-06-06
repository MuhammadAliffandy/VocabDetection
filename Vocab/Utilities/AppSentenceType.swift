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
    
    // Conforming to Identifiable requires an ID.
    // We can just use the case itself as the unique identifier.
    var id: Self { self }
    
    // Returns the exact text shown in your design
    var title: String {
        switch self {
        case .statement: return "Pernyataan"
        case .question: return "Pertanyaan"
        case .command: return "Perintah"
        case .exclamation: return "Seruan"
        }
    }
    
    // Returns the exact SF Symbol names that match your design
    var iconName: String {
        switch self {
        case .statement: return "info.bubble.fill"
        case .question: return "questionmark.bubble.fill"
        case .command: return "speaker.wave.2.bubble.fill"
        case .exclamation: return "exclamationmark.bubble.fill"
        }
    }
}
