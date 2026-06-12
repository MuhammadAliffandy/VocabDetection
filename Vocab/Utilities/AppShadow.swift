//
//  AppShadow.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 12/06/26.
//

import SwiftUI

extension View {

    func AppShadowCamera() -> some View {
        self.shadow(
            color: Color.black.opacity(0.28),
            radius: 6,
            x: 0,
            y: 4
        )
    }
    
    func AppShadowVocabCard() -> some View {
        self.shadow(
            color: Color.black.opacity(0.25),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    
    
}
