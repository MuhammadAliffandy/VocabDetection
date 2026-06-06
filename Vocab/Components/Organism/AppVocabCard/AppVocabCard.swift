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
    var onTapGesture: () -> Void = {}
    
    
    var body: some View{
        VStack(
            alignment: .center,
            spacing: 10
        ){
            ZStack {
                Color.white
                    .clipShape(.rect(cornerRadius: 16))
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black)
                    .clipShape(.rect(cornerRadius: 16))

                      
                }
                .aspectRatio(1.0, contentMode: .fit)
                .onTapGesture {
                    onTapGesture()
                }
            
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
                image: AppImageAsset.dummyImage,
                title: "Orang",
                onTapGesture: {
                    print("test")
                }
            )
            AppVocabCard(
                image: AppImageAsset.dummyImage,
                title: "Orang",
            )
            AppVocabCard(
                image: AppImageAsset.dummyImage,
                title: "Orang",
            )
            AppVocabCard(
                image: AppImageAsset.dummyImage,
                title: "Orang",
            )
            
        }
        .padding(16)
    }
    .background(Color(UIColor.systemGroupedBackground))
}
