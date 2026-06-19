import Foundation

protocol LLMServiceProtocol {
    var isAvailable: Bool { get }
    func generateSentences(from keywords: [String]) async throws -> (sentences: [AppSentenceType: String], pronunciation: String)
    func chunkSentence(sentence: String) -> [String]
}
