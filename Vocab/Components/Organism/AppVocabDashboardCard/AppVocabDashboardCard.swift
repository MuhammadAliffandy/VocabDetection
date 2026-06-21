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
            
            VStack(alignment: .leading, spacing: 4) {
                AppHeadline(
                    title: title,
                    subtitle: subtitle,
                    titleStyle: .appHeadlinev2,
                    subtitleStyle: .appHeadlinev2,
                    titleColor: .primary,
                    subtitleColor: .primary,
                    spacing: AppSpacing.textSpacing
                )
                
                AppText(
                    text: count,
                    fontStyle: .appLargeTitle,
                    textColor: .primary
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.shapeRadius)
                .fill(Color.brandColorPrimaryTeal.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.shapeRadius)
                .strokeBorder(Color.brandColorPrimaryTeal.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.shapeRadius))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
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
