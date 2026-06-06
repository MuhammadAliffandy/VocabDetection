//
//  AppText.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppText: View {
    
    var text: String = "Text Default"
    var fontStyle: Font = .appHeadline
    var textColor: Color = Color.textColorPrimarySemiBlack
        
        var body: some View {
            Text(text)
                .font(fontStyle)
                .foregroundStyle(textColor)
                
        }
}


#Preview {
    AppText(
        text: "Default Example",
        fontStyle: .appHeadline,
        textColor: Color.textColorPrimarySemiBlack
    )
}
