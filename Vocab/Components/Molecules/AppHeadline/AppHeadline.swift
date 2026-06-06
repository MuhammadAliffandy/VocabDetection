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
    var spacing: CGFloat = 10
    
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
        }
        .padding(0)
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
