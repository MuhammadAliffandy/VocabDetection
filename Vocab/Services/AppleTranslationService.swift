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
            return text
        }
        
        do {
            let response = try await session.translate(text)
            return response.targetText
        } catch {
            return text // Fallback jika gagal
        }
    }
}
