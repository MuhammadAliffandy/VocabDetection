//
//  ResultLoadingView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct ResultLoadingView: View {
    
    @State private var navigateToResult = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ProgressView()
                .controlSize(.large)
            
            Spacer()
            
            AppHeadline(
                title: "Memindai kosa kata...",
                subtitle: "Memindai kata dari gambar yang sudah kamu ambil",
                titleStyle: .appTitle,
                subtitleStyle: .appHeadline,
                aligment: .leading,
                isFullWidth: true
            )
            .padding(.bottom, 80)
        }
        .padding(AppPadding.areaPadding)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                navigateToResult = true
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView()
        }
    }
}

#Preview {
    NavigationStack {
        ResultLoadingView()
    }
}
