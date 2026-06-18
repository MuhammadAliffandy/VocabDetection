//
//  ContentView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
        if hasSeenOnboarding {
            MainTabView()
            
        } else {
            OnboardingView()

        }
    }
}

#Preview {
    ContentView()
}
