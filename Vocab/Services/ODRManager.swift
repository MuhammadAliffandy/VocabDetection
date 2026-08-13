//
//  ODRManager.swift
//  Vocab
//

import Foundation
import Combine
import SwiftUI

/// Mengelola pengunduhan aset On-Demand Resources (ODR) dari server Apple
@MainActor
class ODRManager: ObservableObject {
    static let shared = ODRManager()
    
    @Published var isDownloading: Bool = false
    @Published var progress: Double = 0.0
    @Published var isReady: Bool = false
    @Published var error: Error?
    
    private var request: NSBundleResourceRequest?
    private var progressObservation: NSKeyValueObservation?
    
    private init() {}
    
    /// Meminta aset ODR berdasarkan tag yang dikonfigurasi di Xcode (Resource Tags).
    /// Jika aset sudah ada di perangkat, metode ini akan langsung mengembalikan nilai tanpa perlu mendownload.
    func requestResource(with tag: String) async throws {
        // Jika sedang men-download, tunggu
        if isDownloading {
            while isDownloading {
                try await Task.sleep(nanoseconds: 500_000_000)
            }
            if isReady { return }
        }
        
        request = NSBundleResourceRequest(tags: [tag])
        
        // Cek dulu apakah file sudah tersedia secara lokal tanpa mendownload
        let isAvailable = await request?.conditionallyBeginAccessingResources() ?? false
        
        if isAvailable {
            self.isReady = true
            return
        }
        
        // Jika belum ada, mulai download dari server App Store
        self.isDownloading = true
        self.progress = 0.0
        
        // Pantau persentase unduhan
        progressObservation = request?.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.progress = progress.fractionCompleted
            }
        }
        
        do {
            try await request?.beginAccessingResources()
            
            // Selesai download
            self.progressObservation?.invalidate()
            self.progressObservation = nil
            self.isDownloading = false
            self.isReady = true
            
        } catch {
            self.progressObservation?.invalidate()
            self.progressObservation = nil
            self.isDownloading = false
            self.error = error
            throw error
        }
    }
    
    /// Mengakhiri akses ke resource (membiarkan iOS membersihkan storage jika butuh memori).
    func endAccess() {
        request?.endAccessingResources()
        isReady = false
    }
}
