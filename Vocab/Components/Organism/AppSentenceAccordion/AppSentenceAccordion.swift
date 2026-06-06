//
//  AppSentenceAccordion.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppSentenceAccordion: View {
    var body: some View {
        AppAccordion(
            header: {
                AppAccordionHeader()
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
                    
                    AppSentenceGroup()
                }
            }
        )
        .padding(AppPadding.shapePadding)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        
    }
}


#Preview {
    VStack{
        AppSentenceAccordion()
    }
    .frame(width: .infinity, height: .infinity)
    .ignoresSafeArea()

}
