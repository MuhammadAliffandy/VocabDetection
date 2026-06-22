import CoreImage
import Foundation
import MLX
import MLXHuggingFace
import MLXLMCommon
import MLXVLM
import Tokenizers
import UIKit

/// Objects FastVLM found in a photo.
struct SceneResult {
    var object: String
}

@MainActor
@Observable
final class FastVLMService {

    enum LoadState: Equatable {
        case idle
        case loading
        case ready
        case failed(String)
    }

    private(set) var loadState: LoadState = .idle
    private var container: ModelContainer?

    private static let modelFolderName = "FastVLMModel"

    // MARK: - Model loading

    /// Loads the FastVLM model from the app bundle. No network is used.
    /// Safe to call repeatedly.
    func ensureLoaded() async {
        switch loadState {
        case .ready, .loading:
            return
        case .idle, .failed:
            break
        }

        loadState = .loading
        do {
            // Keep MLX's buffer cache small so an unload actually returns
            // memory to the OS instead of being held by the allocator.
            MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

            await FastVLM.register(modelFactory: VLMModelFactory.shared)

            var modelURL: URL? = Bundle.main.url(forResource: Self.modelFolderName, withExtension: nil)
            if modelURL == nil {
                if let configURL = Bundle.main.url(forResource: "config", withExtension: "json", subdirectory: Self.modelFolderName) {
                    modelURL = configURL.deletingLastPathComponent()
                } else if let configURL = Bundle.main.url(forResource: "config", withExtension: "json") {
                    modelURL = configURL.deletingLastPathComponent()
                }
            }

            guard let finalModelURL = modelURL else {
                loadState = .failed(
                    "Folder model '\(Self.modelFolderName)' tidak ditemukan di app bundle.")
                return
            }
            let container = try await VLMModelFactory.shared.loadContainer(
                from: finalModelURL,
                using: #huggingFaceTokenizerLoader()
            )
            self.container = container
            loadState = .ready
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    /// Releases the FastVLM weights so the iPhone gets its memory back.
    /// The next call to `ensureLoaded()` will reload from the bundle.
    func unload() {
        container = nil
        // Returning unused GPU/Metal buffers to the OS.
        MLX.GPU.set(cacheLimit: 0)
        MLX.GPU.clearCache()
        loadState = .idle
    }

    // MARK: - Vision tasks

    /// Asks FastVLM what objects are in the photo and what the setting is.
    func detectScene(in image: UIImage) async throws -> SceneResult {
        let reply = try await respond(
            to: """
            Identify the single main object in this image.
            Respond with EXACTLY ONE NOUN in English (e.g. 'cat', 'bottle', 'chair').
            Do not include articles like 'a', 'an', or 'the'.
            Do not write sentences or descriptions.
            Just the one word name of the object.
            """,
            about: image
        )
        return parseScene(reply)
    }

    // MARK: - Inference

    private func respond(to prompt: String, about image: UIImage) async throws -> String {
        guard let container else { throw ServiceError.notLoaded }
        guard let ciImage = Self.ciImage(from: image) else { throw ServiceError.badImage }
        
        // Create ChatSession in its own scope so it can be released promptly
        // after inference, freeing KV-cache and activation buffers from GPU memory.
        let reply: String = try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let session = ChatSession(container)
                    let result = try await session.respond(to: prompt, image: .ciImage(ciImage))
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Flush any MLX intermediate buffers accumulated during inference
        MLX.GPU.clearCache()
        
        return reply
    }

    enum ServiceError: LocalizedError {
        case notLoaded
        case badImage

        var errorDescription: String? {
            switch self {
            case .notLoaded: return "The model is not loaded yet."
            case .badImage: return "Could not read the selected image."
            }
        }
    }

    private static func ciImage(from image: UIImage) -> CIImage? {
        if let ci = image.ciImage { return ci }
        if let cg = image.cgImage { return CIImage(cgImage: cg) }
        return CIImage(image: image)
    }

    // MARK: - Parsing the model's text output

    private func parseScene(_ text: String) -> SceneResult {
        // 1. Clean punctuation
        let charactersToRemove = CharacterSet.punctuationCharacters
        let cleaned = text.components(separatedBy: charactersToRemove).joined(separator: "")
        
        // 2. Split into words
        let words = cleaned.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            
        // 3. Filter out common conversational/stop words that VLM might output if it ignores the prompt
        let stopWords: Set<String> = [
            "a", "an", "the", "this", "is", "object", "objects", "i", "see",
            "picture", "image", "photo", "shows", "main", "prominent", "foreground", "it"
        ]
        
        let meaningfulWords = words.filter { !stopWords.contains($0.lowercased()) }
        
        // 4. Use the last meaningful word as the object noun (e.g., "red apple" -> "apple")
        // If empty (e.g. model outputted nothing useful), fallback to "Unknown"
        let finalWord = meaningfulWords.last ?? "Unknown"
        
        return SceneResult(object: finalWord.capitalized)
    }
}
