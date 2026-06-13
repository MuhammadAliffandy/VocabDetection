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
        HStack{
            
            Image(systemName: AppIcon.MagnifyingGlassIcon)
                .foregroundStyle(.primary)
                .padding(.leading,AppPadding.shapePadding * 1.5 )
            
            TextField(
                "",
                text: $text,
                prompt: Text("Masukkan Vocabulary . . .")
                        .foregroundStyle(.gray)
                
            )
            .padding(.vertical,AppPadding.shapePadding * 1.5)
            .padding(.trailing,AppPadding.shapePadding * 1.5 )
            .font(.appHeadline)
            .foregroundStyle(Color.black)
        
        }
        .adaptiveBackground()
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
