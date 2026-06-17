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
        loadState = .idle
    }

    // MARK: - Vision tasks

    /// Asks FastVLM what objects are in the photo and what the setting is.
    func detectScene(in image: UIImage) async throws -> SceneResult {
        let reply = try await respond(
            to: """
            Look at this photo. Identify ONLY the single most prominent, largest, and dominant foreground object (can be anything like an everyday item, person, animal, plant, etc.), and nothing else. Do NOT describe the setting or situation.
            Answer in exactly this format and nothing else:
            OBJECTS: this is [object]
            """,
            about: image
        )
        return parseScene(reply)
    }

    // MARK: - Inference

    private func respond(to prompt: String, about image: UIImage) async throws -> String {
        guard let container else { throw ServiceError.notLoaded }
        guard let ciImage = Self.ciImage(from: image) else { throw ServiceError.badImage }
        let session = ChatSession(container)
        return try await session.respond(to: prompt, image: .ciImage(ciImage))
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
        for line in text.components(separatedBy: .newlines) {
            var cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanLine.isEmpty { continue }
            
            let fullPrefix = "OBJECTS: this is "
            let shortPrefix = "OBJECTS: "
            let singlePrefix = "OBJECT: "
            
            if cleanLine.lowercased().hasPrefix(fullPrefix.lowercased()) {
                cleanLine = String(cleanLine.dropFirst(fullPrefix.count))
            } else if cleanLine.lowercased().hasPrefix(shortPrefix.lowercased()) {
                cleanLine = String(cleanLine.dropFirst(shortPrefix.count))
            } else if cleanLine.lowercased().hasPrefix(singlePrefix.lowercased()) {
                cleanLine = String(cleanLine.dropFirst(singlePrefix.count))
            }
            
            cleanLine = cleanLine.trimmingCharacters(in: .whitespacesAndNewlines)
            cleanLine = cleanLine.replacingOccurrences(of: ".", with: "")
            
            return SceneResult(object: cleanLine.isEmpty ? "Unknown" : cleanLine)
        }
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return SceneResult(object: trimmed.isEmpty ? "Unknown" : trimmed)
    }
}
