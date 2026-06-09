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
    var subtitle: String
    var onTapGesture: () -> Void = {}
    
    
    var body: some View{
        VStack(
            alignment: .leading,
            spacing: 8
        ){
            ZStack {
                Color.white
                    .clipShape(.rect(cornerRadius: 16))
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.black)
                    .clipShape(.rect(cornerRadius: AppRadius.vocabShapeRadius))

                      
                }
                .aspectRatio(1.0, contentMode: .fit)
                .onTapGesture {
                    onTapGesture()
                }
                .overlay(
                    VStack{
                        Spacer()
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, Color.brandColorPrimaryTeal.opacity(0.5)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .frame(height: 60)
                    }
                )
            
            AppHeadline(
                title: title,
                subtitle: subtitle,
                titleStyle: .appHeadlinev2,
                subtitleStyle: .appSubheadline,
                subtitleColor: .textColorSecondaryBlackGrey,
                spacing: AppSpacing.textSpacing
            )
            .padding(.leading ,11)
            .padding(.bottom, 8)
            
        }
        .padding(4)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        
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
                title: "Chair",
                subtitle: "Kursi",
                onTapGesture: {
                    print("test")
                }
            )
            
            
        }
        .padding(16)
    }
    .background(Color(UIColor.systemGroupedBackground))
}
