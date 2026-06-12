//
//  AppHeadline.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppHeadline: View {
    
    var title: String
    var subtitle: String
    var titleStyle: Font =  .appHeadlinev2
    var subtitleStyle: Font = .appSubheadline
    var titleColor: Color = Color.textColorPrimarySemiBlack
    var subtitleColor: Color = Color.textColorSecondaryBlackGrey
    var aligment: HorizontalAlignment = .leading
    var spacing: CGFloat = AppSpacing.regular
    var textAlign: TextAlignment = .leading
    
    var isFullWidth: Bool = true
    
    var body: some View {
        VStack(
            alignment: aligment,
            spacing: spacing
        ){
            AppText(
                text: title,
                fontStyle: titleStyle,
                textColor: titleColor
            )
            AppText(
                text: subtitle,
                fontStyle: subtitleStyle,
                textColor: subtitleColor
            )
            .multilineTextAlignment(textAlign)
        }
        .padding(0)
        .frame(
            maxWidth: isFullWidth ? .infinity : nil,
            alignment: .leading
        )
    }
}

#Preview{
    VStack(alignment: .leading){
        AppHeadline(
            title: "Hay" ,
            subtitle : "ini adalah subtitile",
            aligment: .leading
        )
    }
}
