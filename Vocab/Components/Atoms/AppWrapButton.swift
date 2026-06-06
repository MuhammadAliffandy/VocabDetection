//
//  AppWrapButton.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppWrapButton<Content: View>:View{
    
    var action: () -> Void
    @ViewBuilder let component: Content
    
    var body: some View{
        Button(
            action: action
        ){
            component
        }
        
    }
}
