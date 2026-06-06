//
//  AppVocabCard.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppVocabCard: View {
    
    var image: String
    var title: String
    
    var body: some View{
        VStack(
            alignment: .center,
            spacing: 10
        ){
            ZStack {
                Color.white
                    .clipShape(.rect(cornerRadius: 16))
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black)

                      
                }
                .aspectRatio(1.0, contentMode: .fit)
            
            AppText(
                text: title,
                fontStyle: .appHeadline,
                textColor: Color.textColorPrimarySemiBlack
            )
            
        }
    }
}

#Preview {

    let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    ScrollView {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            
            AppVocabCard(
                image: "person.fill",
                title: "Orang"
            )
            
            AppVocabCard(
                image: "house.fill",
                title: "Rumah"
            )

            AppVocabCard(
                image: "car.fill",
                title: "Mobil"
            )
    
            AppVocabCard(
                image: "tree.fill",
                title: "Pohon"
            )
            
        }
        .padding(16)
    }
    .background(Color(UIColor.systemGroupedBackground))
}
