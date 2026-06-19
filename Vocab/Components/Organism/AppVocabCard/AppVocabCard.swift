//
//  AppVocabCard.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppVocabCard: View {
    
    var image: String
    var imageData: Data? = nil
    var title: String
    var subtitle: String
    var isEditingMode: Bool = false
    var isSelected: Bool = false
    var onTapGesture: () -> Void = {}
    var onLongPressGesture: (() -> Void)? = nil
    
    
    var body: some View{
        VStack(
            alignment: .leading,
            spacing: 8
        ){
            ZStack {
                Color.white
                    .clipShape(.rect(cornerRadius: 16))
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .clipped()
                } else {
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .clipped()
                }

                      
            }
            .clipShape(.rect(cornerRadius: AppRadius.vocabShapeRadius))
            .aspectRatio(1.0, contentMode: .fit)
                .onTapGesture {
                    onTapGesture()
                }
                .onLongPressGesture {
                    if let longPress = onLongPressGesture {
                        longPress()
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if isEditingMode {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(isSelected ? .brandColorPrimaryTeal : .white)
                            .background {
                                Circle().fill(Color.white).opacity(isSelected ? 1.0 : 0.0)
                            }
                            .shadow(color: .black.opacity(0.3), radius: 2)
                            .padding(8)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            
            AppHeadline(
                title: title,
                subtitle: subtitle,
                titleStyle: .appHeadlinev2,
                subtitleStyle: .appSubheadline,
                titleColor: .primary,
                subtitleColor: .textColorSecondaryBlackGrey,
                spacing: AppSpacing.textSpacing
            )
            .padding(.leading ,11)
            .padding(.bottom, 8)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(4)
        .adaptiveBackground()
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        .AppShadowVocabCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityHint(isEditingMode ? (isSelected ? "Ketuk untuk membatalkan pilihan" : "Ketuk untuk memilih") : "Ketuk untuk melihat detail kosakata")
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        
    }
}

#Preview {

    let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    ScrollView {
        VStack{
            LazyVGrid(columns: gridColumns, spacing: 16) {
                
                AppVocabCard(
                    image: AppImageAsset.dummyImage,
                    title: "Chair ADKDASDJASAHJAKDJKDHJKSDJADHA",
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
            .padding(16)
        }
    }
    .background(Color(UIColor.systemGroupedBackground))
}
