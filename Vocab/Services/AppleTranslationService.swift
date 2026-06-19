//
//  AppleTranslationService.swift
//  Vocab
//

import Foundation
import Translation

@available(iOS 17.4, *)
class AppleTranslationService: TranslationServiceProtocol {
    
    var session: TranslationSession?
    
    func translate(text: String) async throws -> String {
        guard let session = session else {
            // print("AppleTranslationService: No TranslationSession provided. Returning original text.")
            return text
        }
        
        do {
            let response = try await session.translate(text)
            return response.targetText
        } catch {
            // print("AppleTranslationService Error: \(error.localizedDescription)")
            return text // Fallback jika gagal
        }
    }
}
