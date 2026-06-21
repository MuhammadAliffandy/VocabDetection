//
//  AppDraggableWordOption.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 20/06/26.
//

import SwiftUI

struct AppDraggableWordOption: View {
    var word: String

    var body: some View {
        Text(word)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(Color.brandColorPrimaryTeal)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
            .shadow(
                color: .brandColorPrimaryTeal.opacity(0.25),
                radius: 6,
                x: 0,
                y: 4
            )
    }
}

#Preview {
    HStack(spacing: 16) {
        AppDraggableWordOption(word: "apple")
        AppDraggableWordOption(word: "banana")
        AppDraggableWordOption(word: "orange")
    }
    .padding()
}
