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
                prompt: Text("Kursi, Kacamata...")
                        .foregroundStyle(.gray)
                
            )
            .padding(.vertical,AppPadding.shapePadding * 1.5)
            .padding(.trailing,AppPadding.shapePadding * 1.5 )
            .font(.appHeadline)
            .foregroundStyle(.primary)
            .onAppear {
                UITextField.appearance().clearButtonMode = .never
            }
       
        
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: .infinity))
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .glassEffect()
      
        
    }
}


struct CreateTextField: View{
    @State private var typping: String = ""
    
    var body: some View{
        AppTextField(text: $typping)

    }
}


#Preview {
    VStack{
        
        Spacer()
        
        CreateTextField()
        
        Spacer()
        
    }
    .background(.red)
    
    
}
