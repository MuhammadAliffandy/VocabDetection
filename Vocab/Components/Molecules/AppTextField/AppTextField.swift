//
//  AppTextField.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppTextField: View {
    
    @Binding var text: String
    
    var body: some View{
        TextField(
            "Masukkan Vocabulary . . .", text: $text,
        )
        .font(.appHeadline)
        .padding(AppPadding.shapePadding * 1.5)
        .foregroundStyle(Color.black)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: .infinity))

    }
}


struct CreateTextField: View{
    @State private var typping: String = ""
    
    var body: some View{
        AppTextField(text: $typping)

    }
}


#Preview {
    CreateTextField()
}
