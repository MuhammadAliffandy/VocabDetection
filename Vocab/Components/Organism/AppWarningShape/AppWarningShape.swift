//
//  AppWarningShape.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 12/06/26.
//

import SwiftUI

struct AppWarningShape: View{
    var body: some View{
        VStack(
            alignment: .center, 
            spacing: AppSpacing.regular){
            
            Image(systemName: AppIcon.ExclamationmarkTriangleIcon)
                .font(.system(size: AppIconSize.Regular))
                .foregroundStyle(.white)
            
            AppText(
                text :"Allow Apple Intelligent to get example sentence",
                textColor: .white
            )
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppPadding.areaPadding)
        .background(Color.colorRedWarning)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
    }
}

#Preview{
    AppWarningShape()
}
