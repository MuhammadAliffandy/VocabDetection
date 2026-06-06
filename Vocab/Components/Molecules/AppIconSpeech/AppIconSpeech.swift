//
//  AppIconSpeech.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppIconSpeech: View {
    
    var action: () -> Void

    var body: some View {
        AppWrapButton(action: action){
            Image(systemName: AppIcon.SpeakerWave3Icon)
                .font(.system(size: AppIconSize.Small))
                .foregroundColor(Color.white)
                .padding(12)
                .background(Color.brandColorPrimaryTeal)
                .clipShape(Circle())
                            
        }
    }
}


#Preview {
    AppIconSpeech(action: {
        
    })
}
