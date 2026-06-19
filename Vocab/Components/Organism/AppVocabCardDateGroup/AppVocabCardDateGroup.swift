//
//  AppVocabCardDateGroup.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 09/06/26.
//

import SwiftUI


struct AppVocabCardDateGroup<Component: View , TrailingComponent: View>: View {
    
    private let rows = [
            GridItem(.flexible())
        ]
    
    
    var title: String = "Title"
    @ViewBuilder var trailingComponent: TrailingComponent
    @ViewBuilder var component: Component

    var body: some View {
        VStack(alignment: .leading){
            
            HStack{
                AppText(
                    text: title,
                    fontStyle: .appHeadlinev2
                )
                
                Spacer()
                
                trailingComponent
                
            }
            
            
            ScrollView (.horizontal, showsIndicators: false){
                LazyHGrid(rows: rows, spacing: AppSpacing.regular) {
                    component
                }
                .frame(height: 250)
      
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    AppVocabCardDateGroup(
        
        trailingComponent: {
           
        },
        
        component: {
            AppVocabCard(
                image: AppImageAsset.dummyImage,
                title: "Chair",
                subtitle: "Kursi",
                onTapGesture: {
                    // print("test")
                }
            )
            
            AppVocabCard(
                image: AppImageAsset.dummyImage,
                title: "Chair",
                subtitle: "Kursi",
                onTapGesture: {
                    // print("test")
                }
            )
            AppVocabCard(
                image: AppImageAsset.dummyImage,
                title: "Chair",
                subtitle: "Kursi",
                onTapGesture: {
                    // print("test")
                }
            )
        }
    )
}
