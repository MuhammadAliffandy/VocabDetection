//
//  AppVocabDashboardCard.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 08/06/26.
//

import SwiftUI

struct AppVocabDashboardCard: View {
    
    var icon: String
    var title: String
    var subtitle: String
    var count: String
    
    var body: some View {
        VStack(alignment: .leading,
               spacing: AppSpacing.regular
        ){
            
            Image(systemName: icon)
                .font(.system(size: AppIconSize.Small))
                .foregroundColor(Color.brandColorPrimaryTeal)
            
            VStack ( alignment: .leading, spacing: 4){
                AppHeadline(
                    title: title,
                    subtitle: subtitle,
                    titleStyle: .appHeadlinev2,
                    subtitleStyle: .appHeadlinev2,
                    subtitleColor: Color.textColorPrimarySemiBlack,
                    spacing: AppSpacing.textSpacing
                )
                
        
                AppText(
                    text: count,
                    fontStyle: .appLargeTitle,
                    textColor: .black
                   
                )
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
    }
}

#Preview {
    HStack{
        AppVocabDashboardCard(
            icon:AppIcon.BookPagesIcon,
            title: "Total",
            subtitle: "Kosakata",
            count: "0"
        )
        
        AppVocabDashboardCard(
            icon:AppIcon.ClockBadgeCheckmarkIcon,
            title: "Total",
            subtitle: "Kosakata",
            count: "0"
        )
        
        
    }
}
