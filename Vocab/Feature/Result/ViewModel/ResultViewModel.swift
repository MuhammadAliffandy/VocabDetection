import Foundation
import Combine
import Translation

struct GeneratedSentence: Identifiable {
    let id = UUID()
    let type: AppSentenceType
    let text: String
    let meaning: String
}

@MainActor
class ResultViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var generatedSentences: [GeneratedSentence] = []
    @Published var vocabDictionary: [String: String] = [:]
    @Published var dynamicPronunciation: String = ""
    
    private let llmService: LLMServiceProtocol
    private let translationService: TranslationServiceProtocol
    private let ttsService: TextToSpeechServiceProtocol
    
    var isAppleIntelligenceAvailable: Bool {
        return llmService.isAvailable
    }
    
    // Inisialisasi biasa pada ViewModel, default menggunakan real service
    @available(iOS 18.0, *)
    init(llmService: LLMServiceProtocol = AppleIntelligenceLLMService(),
         translationService: TranslationServiceProtocol = AppleTranslationService(),
         ttsService: TextToSpeechServiceProtocol = TextToSpeechService()) {
        self.llmService = llmService
        self.translationService = translationService
        self.ttsService = ttsService
    }
    
    @available(iOS 17.4, *)
    func setTranslationSession(_ session: TranslationSession) {
        if let appleService = translationService as? AppleTranslationService {
            appleService.session = session
        }
    }
    
    func processDetectedObjects(_ objects: [String]) async {
        isLoading = true
        do {
                let llmResult = try await llmService.generateSentences(from: objects)
                let sentencesDict = llmResult.sentences
                self.dynamicPronunciation = llmResult.pronunciation
                
                // 2. Terjemahkan kata-kata dasar dari deteksi
                var dict: [String: String] = [:]
                let firstWord = objects.first ?? "object"
                let cleanFirstWord = firstWord.lowercased()
                let translatedFirstWord = try await translationService.translate(text: cleanFirstWord)
                if translatedFirstWord.lowercased() != cleanFirstWord {
                    dict[cleanFirstWord] = translatedFirstWord
                } else {
                    dict[cleanFirstWord] = cleanFirstWord
                }
                
                // Hanya skip artikel, konjungsi murni, dan preposisi pendek
                // Semua kata lain (noun, verb, adj, pronoun, adv) WAJIB masuk dictionary
                let stopWords: Set<String> = [
                    "a", "an", "the",           // artikel
                    "and", "or", "but", "so",   // konjungsi
                    "in", "on", "at", "to",     // preposisi pendek
                    "of", "by", "as", "if",
                    "is", "am", "are",           // to be
                    "be", "been", "being"
                ]
                
                // 3. Terjemahkan setiap kalimat yang digenerate dan chunking untuk vocabDictionary
                var generatedList: [GeneratedSentence] = []
                for (type, sentence) in sentencesDict {
                    let translatedSentence: String
                    do {
                        let result = try await translationService.translate(text: sentence)
                        // Jika terjemahan sama dengan input (gagal download), pakai teks asli
                        translatedSentence = result.lowercased() == sentence.lowercased() ? sentence : result
                    } catch {
                        translatedSentence = sentence // fallback ke kalimat Inggris asli
                    }
                    generatedList.append(GeneratedSentence(type: type, text: sentence, meaning: translatedSentence))
                    
                    let words = llmService.chunkSentence(sentence: sentence)
                    for word in words {
                        let cleanWord = word.lowercased()
                        // Skip stop words dan kata yang sudah ada di dictionary
                        guard !stopWords.contains(cleanWord) && dict[cleanWord] == nil else { continue }
                        // Skip kata yang terlalu pendek (1 karakter)
                        guard cleanWord.count > 1 else { continue }
                        
                        let translatedWord = try await translationService.translate(text: cleanWord)
                        // Selalu simpan — meski translation gagal (return kata yang sama),
                        // tetap masukkan supaya tooltip tetap muncul
                        dict[cleanWord] = translatedWord
                    }
                }
                
                // Sort by predefined order
                generatedList.sort { $0.type.sortOrder < $1.type.sortOrder }
                
                // Update State
                self.generatedSentences = generatedList
                self.vocabDictionary = dict
                self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }
    
    func speakSentence(text: String) {
        guard !text.isEmpty else { return }
        ttsService.speak(text: text, language: "en-US")
    }
    
    func getIPA(for word: String) -> String {
        let lowerWord = word.lowercased()
        
        // Jika LLM berhasil membuat phonetic BERBEDA dari kata aslinya, pakai itu
        if !dynamicPronunciation.isEmpty && dynamicPronunciation.lowercased() != lowerWord {
            return "/\(dynamicPronunciation.lowercased())/"
        }
        
        // Selalu gunakan PhoneticService sebagai sumber utama (deterministik, offline)
        let phonetic = PhoneticService.phonetic(for: lowerWord)
        return "/\(phonetic)/"
    }
}
