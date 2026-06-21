//
//  VocabApp.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI
import SwiftData

@main
struct VocabApp: App {
    
    let container: ModelContainer = {
        let schema = Schema([VocabItem.self, VocabSentence.self, DailyStreak.self])
        // isAutosaveEnabled true + migration ringan otomatis
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: nil,
                configurations: [config]
            )
        } catch {
            // Jika schema conflict (misal ada field baru), hapus store lama dan buat ulang
            let config2 = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            do {
                return try ModelContainer(for: schema, configurations: [config2])
            } catch {
                fatalError("Tidak bisa membuat ModelContainer: \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color(UIColor.systemGroupedBackground))
                .modelContainer(container)
        }
    }
}
