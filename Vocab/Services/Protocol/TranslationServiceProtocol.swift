import Foundation


protocol TranslationServiceProtocol {
    func translate(text: String) async throws -> String
}

