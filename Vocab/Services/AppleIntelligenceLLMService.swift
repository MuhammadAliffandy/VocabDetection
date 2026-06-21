//
//  AppleIntelligenceLLMService.swift
//  Vocab
//

import Foundation
import NaturalLanguage

// Menggunakan Framework Apple Intelligence (iOS 18)
#if canImport(FoundationModels)
import FoundationModels
#endif

@available(iOS 18.0, *)
class AppleIntelligenceLLMService: LLMServiceProtocol {
    
    #if canImport(FoundationModels)
    private var session: LanguageModelSession?
    #endif
    
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        return self.session != nil
        #else
        return false
        #endif
    }
    
    init() {
        #if canImport(FoundationModels)
        // Inisialisasi LanguageModelSession dengan instruksi khusus (System Prompt)
        let systemPrompt = """
        You are a creative English teacher. You will be given a single word representing a physical object detected by a camera.
        CRITICAL: The word is ALWAYS a NOUN representing a physical object (e.g. if the word is 'watch', it means a wristwatch, NOT the verb 'to watch').
        
        Create exactly 4 very basic, simple, and easy-to-use English sentences that actively use that exact noun.
        Provide exactly one Statement, one Question, one Command, and one Exclamation.
        Also, you MUST provide the Indonesian phonetic spelling (cara baca lokal) of the word. DO NOT just repeat the English word! 
        Examples of phonetic spelling: 
        - 'chair' -> 'ceir'
        - 'shoe' -> 'syu'
        - 'watch' -> 'woc'
        Format your response EXACTLY like this with no extra text:
        PRONUNCIATION: [indonesian phonetic spelling]
        STATEMENT: [your simple sentence]
        QUESTION: [your simple sentence]
        COMMAND: [your simple sentence]
        EXCLAMATION: [your simple sentence]
        """
        self.session = LanguageModelSession(instructions: systemPrompt)
        #else
        #endif
    }
    
    func chunkSentence(sentence: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = sentence
        
        var chunks: [String] = []
        tokenizer.enumerateTokens(in: sentence.startIndex..<sentence.endIndex) { tokenRange, _ in
            let word = String(sentence[tokenRange])
            chunks.append(word)
            return true
        }
        
        return chunks
    }
    
    func generateSentences(from keywords: [String]) async throws -> (sentences: [AppSentenceType: String], pronunciation: String) {
        let primaryWord = keywords.first ?? "object"
        var rawResponse = ""
        
        #if canImport(FoundationModels)
        if let session = self.session {
            do {
                let response = try await session.respond(to: "The word is: \(primaryWord)")
                rawResponse = response.content
            } catch {
                rawResponse = generateMockResponse(for: primaryWord)
            }
        } else {
            rawResponse = generateMockResponse(for: primaryWord)
        }
        #else
        rawResponse = generateMockResponse(for: primaryWord)
        #endif
        
        // Parser AI Response ke Dictionary Enum
        var resultDict: [AppSentenceType: String] = [:]
        var pronunciation: String = ""
        let lines = rawResponse.components(separatedBy: .newlines)
        
        for line in lines {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanLine.hasPrefix("PRONUNCIATION:") {
                pronunciation = String(cleanLine.dropFirst(14)).trimmingCharacters(in: .whitespaces)
            } else if cleanLine.hasPrefix("STATEMENT:") {
                resultDict[.statement] = String(cleanLine.dropFirst(10)).trimmingCharacters(in: .whitespaces)
            } else if cleanLine.hasPrefix("QUESTION:") {
                resultDict[.question] = String(cleanLine.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            } else if cleanLine.hasPrefix("COMMAND:") {
                resultDict[.command] = String(cleanLine.dropFirst(8)).trimmingCharacters(in: .whitespaces)
            } else if cleanLine.hasPrefix("EXCLAMATION:") {
                resultDict[.exclamation] = String(cleanLine.dropFirst(12)).trimmingCharacters(in: .whitespaces)
            }
        }
        
        if pronunciation.isEmpty {
            pronunciation = primaryWord
        }
        
        // Fallback jika LLM berhalusinasi atau salah format
        if resultDict.isEmpty {
            resultDict = [
                .statement: "This is a \(primaryWord).",
                .question: "Is this a \(primaryWord)?",
                .command: "Look at the \(primaryWord).",
                .exclamation: "What a nice \(primaryWord)!"
            ]
        }
        return (sentences: resultDict, pronunciation: pronunciation)
    }
    
    // Fungsi bantuan Mock jika perangkat belum support Apple Intelligence
    private func generateMockResponse(for primaryWord: String) -> String {
        return """
        PRONUNCIATION: \(primaryWord)
        STATEMENT: The \(primaryWord) is big.
        QUESTION: Is that a \(primaryWord)?
        COMMAND: Show me the \(primaryWord).
        EXCLAMATION: What a nice \(primaryWord)!
        """
    }
}
