//
//  AppSentenceAccordion.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppSentenceAccordion: View {
    
    var rawSentence: String = "rock is very hard"
    var meaningSentence: String = "batunya sangat keras"
    var vocabDictionary: [String: String] = [
        "rock": "Batudsjhajghf",
        "hard": "Keras"
    ]
    var selectedType: AppSentenceType = .command
    var isAppleIntelligence: Bool = true
    
    var body: some View {
        AppAccordion(
            header: { isExpanded, hasBeenOpened in
                AppAccordionHeader(
                    selectedType: selectedType,
                    isExpanded: isExpanded,
                    hasBeenOpened: hasBeenOpened
                )
            },
            footer: {
                
                VStack(
                    alignment: .leading,
                ){
                    
                    AppText(
                        text: "Klik kosakata pada kalimat untuk melihat artinya",
                        fontStyle: .appSubheadline,
                        textColor: Color.textColorSecondaryBlackGrey
                    )
                    .padding(
                        .vertical, 10
                    )
                    .padding(
                        .horizontal,36
                    )
                   
                    if isAppleIntelligence {
                        AppSentenceGroup(
                            rawSentence: rawSentence,
                            meaningSentence: meaningSentence,
                            vocabDictionary: vocabDictionary
                        )
                        .padding(
                            .horizontal,22
                        )
                    } else{
                        AppWarningShape()
                            .padding(
                                .vertical, 10
                            )
                            .padding(
                                .horizontal,36
                            )
                    }
                   
                }
            }
        )
        .padding(AppPadding.shapePadding)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.shapeRadius)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .contentShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        
    }
}


#Preview {
    VStack{
        AppSentenceAccordion()
        
        AppSentenceAccordion(isAppleIntelligence: false)
    }
    .frame(width: .infinity, height: .infinity)
    .ignoresSafeArea()

}
