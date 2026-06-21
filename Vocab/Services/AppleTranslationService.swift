//
//  AppleTranslationService.swift
//  Vocab
//

import Foundation
import Translation

@available(iOS 17.4, *)
class AppleTranslationService: TranslationServiceProtocol {
    
    // TranslationSession disediakan oleh UI layer melalui modifier .translationTask
    var session: TranslationSession?
    
    func translate(text: String) async throws -> String {
        guard let session = session else {
            return mockTranslate(text)
        }
        
        do {
            let response = try await session.translate(text)
            // Jika API mengembalikan teks yang persis sama, kemungkinan gagal/belum download
            if response.targetText.lowercased() == text.lowercased() {
                return mockTranslate(text)
            }
            return response.targetText
        } catch {
            return mockTranslate(text)
        }
    }
    
    private func mockTranslate(_ text: String) -> String {
        let lowerText = text.lowercased()
        
        // Fallback untuk kalimat Mock dari LLMService
        if lowerText.starts(with: "the ") && lowerText.hasSuffix(" is big.") {
            let word = String(text.dropFirst(4).dropLast(8))
            return "\(word) itu besar."
        }
        if lowerText.starts(with: "is that a ") && lowerText.hasSuffix("?") {
            let word = String(text.dropFirst(10).dropLast(1))
            return "Apakah itu sebuah \(word)?"
        }
        if lowerText.starts(with: "show me the ") && lowerText.hasSuffix(".") {
            let word = String(text.dropFirst(12).dropLast(1))
            return "Tunjukkan padaku \(word) itu."
        }
        if lowerText.starts(with: "what a nice ") && lowerText.hasSuffix("!") {
            let word = String(text.dropFirst(12).dropLast(1))
            return "Betapa bagusnya \(word) ini!"
        }
        
        // Fallback kata benda umum
        let commonWords: [String: String] = [
            "chair": "kursi", "apple": "apel", "bottle": "botol", 
            "laptop": "laptop", "mouse": "tetikus", "keyboard": "papan ketik",
            "cup": "cangkir", "book": "buku", "pen": "pulpen", "shoe": "sepatu",
            "watch": "jam tangan", "phone": "ponsel", "car": "mobil", "table": "meja"
        ]
        
        if let translated = commonWords[lowerText] {
            return translated
        }
        
        return text
    }
}
