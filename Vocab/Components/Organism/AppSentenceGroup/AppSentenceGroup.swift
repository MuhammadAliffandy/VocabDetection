//
//  AppSentenceGroup.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppSentenceGroup: View {

    var rawSentence: String = "rock is very hard even you handled must be broken in the world"
    var meaningSentence: String = "batunya sangat keras"
    var vocabDictionary: [String: String] = [
        "rock": "Batujhfjfkshj",
        "hard": "Keras"
    ]
    
    var body: some View {
        VStack(alignment: .leading ) {
            HStack(
                alignment: .center,
                spacing: 10
            ){
           
//                Image(systemName: AppIcon.CircleFillIcon )
//                    .font(.system(size: 6)
//                )
//                .foregroundStyle(.white)
                
                AppSentenceContent(
                    rawSentence: rawSentence,
                    vocabDictionary: vocabDictionary ,
                    textStyle: .appHeadline
                    
                )

   
            }
            .zIndex(1)
            
           
            
            Divider()
                .frame(height: 1)
                .background( Color.textColorSecondaryBlackGrey.opacity(0.30))
                .padding(.horizontal, 1)
                .padding(.vertical, 0)
                
            
            HStack(
                alignment: .center,
                spacing: 10
            ){
           
//                Image(systemName: AppIcon.CircleFillIcon )
//                    .font(.system(size: 6)
//                )
//                .foregroundStyle(.white)
                
                AppText(
                    text: meaningSentence,
                    textColor: Color.secondary,
                )
            
            }
            .padding(0)
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppRadius.shapeRadius)
                .stroke(
                    Color.textColorSecondaryBlackGrey.opacity(0.30),
                        style: StrokeStyle(lineWidth: 2,
                        lineCap: .round,
                        dash: [6, 6])
                )
        )
    }
}

#Preview {
    AppSentenceGroup(
        
    )
}
