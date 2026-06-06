//
//  AppImage.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppImage: View {
    var image: String
    
    var isSystemIcon: Bool = false
    
    var body: some View {
        ZStack {
          
            
            if isSystemIcon {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black)
            } else {
                Image(image)
                    .resizable()
                    .scaledToFit()
            }
            
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}
