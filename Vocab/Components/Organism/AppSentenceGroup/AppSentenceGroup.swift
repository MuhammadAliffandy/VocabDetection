//
//  AppSentenceGroup.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppSentenceGroup: View {
    var body: some View {
        VStack(alignment: .leading ) {
            HStack(
                alignment: .center,
                spacing: 10
            ){
           
                Image(systemName: AppIcon.CircleFillIcon )
                    .font(.system(size: 6)
                )
                .foregroundStyle(.white)
                
                AppSentenceContent(
                    rawSentence: "rock is very hard",
                    vocabDictionary: [
                        "rock": "Batu",
                        "hard": "Keras"
                    ],
                    textStyle: .appHeadline
                    
                )

   
            }
            .zIndex(1)
            
           
            
            Divider()
                .frame(height: 1)
                .background(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 0)
                .foregroundStyle(.white)
            
            HStack(
                alignment: .center,
                spacing: 10
            ){
           
                Image(systemName: AppIcon.CircleFillIcon )
                    .font(.system(size: 6)
                )
                .foregroundStyle(.white)
                
                AppText(
                    text: "batunya sangat besar",
                    textColor: Color.white,
                )
            }
            .padding(0)
            
        }
        .padding(AppPadding.shapePadding)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.shapeRadius)
                .fill(Color.brandColorPrimaryTeal)
        )
    }
}

#Preview {
    AppSentenceGroup()
}
