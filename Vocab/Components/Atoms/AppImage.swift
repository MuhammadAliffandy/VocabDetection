//
//  AppImage.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppImage: View{
    var image: String
    
    var body: some View{
        ZStack {
            Color.white
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .foregroundColor(.black)

                  
            }
            .aspectRatio(1.0, contentMode: .fit)
    }
}
