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
    
    @State private var cachedImage: UIImage?
    
    
    
    var body: some View{
        VStack(
            alignment: .leading,
            spacing: 8
        ){
            ZStack {
                Color(UIColor.secondarySystemGroupedBackground)
                
                if let uiImage = cachedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipShape(.rect(cornerRadius: 8))
                        .padding(8)
                } else if imageData != nil {
                    ProgressView()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipShape(.rect(cornerRadius: 8))
                        .padding(8)
                } else {
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        // Apply corner radius specifically to the image
                        .clipShape(.rect(cornerRadius: 8))
                        // Apply padding outside the rounded image
                        .padding(8)
                }
            }
            .clipShape(.rect(cornerRadius: AppRadius.vocabShapeRadius))
            .AppShadowVocabCard()
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
            .padding(.bottom, 8)
            .padding(.horizontal , 12)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        .adaptiveBackground()
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        .AppShadowVocabCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityHint(isEditingMode ? (isSelected ? "Ketuk untuk membatalkan pilihan" : "Ketuk untuk memilih") : "Ketuk untuk melihat detail kosakata")
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .task(id: imageData) {
            if let data = imageData, cachedImage == nil {
                let image = await Task.detached(priority: .background) {
                    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
                    guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
                        return UIImage(data: data)
                    }
                    let maxDimensionInPixels: CGFloat = 400
                    let downsampleOptions = [
                        kCGImageSourceCreateThumbnailFromImageAlways: true,
                        kCGImageSourceShouldCacheImmediately: true,
                        kCGImageSourceCreateThumbnailWithTransform: true,
                        kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
                    ] as CFDictionary
                    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
                        return UIImage(data: data)
                    }
                    return UIImage(cgImage: downsampledImage)
                }.value
                await MainActor.run {
                    self.cachedImage = image
                }
            }
        }
        
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
                    }
                )
     
                AppVocabCard(
                    image: AppImageAsset.dummyImage,
                    title: "Chair",
                    subtitle: "Kursi",
                    onTapGesture: {
                    }
                )
         
                
            }
            .padding(16)
        }
    }
    .background(Color(UIColor.systemGroupedBackground))
}
