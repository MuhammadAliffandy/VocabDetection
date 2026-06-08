//
//  AppWrapDropdown.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 08/06/26.
//

import SwiftUI

struct AppWrapDropdown<Parent:View, Child: View >: View {
    
    @ViewBuilder let parent: Parent;
    @ViewBuilder let child: Child;
    
    var body: some View {
        Menu {
            child
        } label: {
            parent
         
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        
        AppWrapDropdown(
            parent:{
                Image(systemName: "ellipsis")
                  .font(.system(size: 24, weight: .bold))
                  .foregroundColor(.black)
                  .frame(width: 44, height: 44)
                  .background(Color.white)
                  .clipShape(Circle())
                  .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            },
            child: {
                Label("Terbaru", systemImage: AppIcon.DocBadgeClockIcon)
                
                Label("Tanggal", systemImage: AppIcon.CalendarIcon)
            }
        )
    }
}
