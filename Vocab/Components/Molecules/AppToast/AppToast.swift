//
//  AppToast.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppToast: View {
    
    var textToast: String
    
    var body: some View{
        AppText(
            text: textToast,
            fontStyle: .appSubheadline,
            textColor: Color.white
        )
        .padding(.horizontal,AppPadding.buttonPadding)
        .padding(.vertical, 7)
        .background(Color.black.opacity(0.30))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.vocabShapeRadius))
        
    }
}


#Preview {
    AppToast(
        textToast: "Default Toast"
    )
}
