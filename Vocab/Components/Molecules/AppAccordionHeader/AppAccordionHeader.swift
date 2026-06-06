//
//  AppAccordionHeader.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppAccordionHeader: View {
        
    @State private var selectedType: AppSentenceType? = .exclamation
    
    var body: some View {
        HStack(alignment: .center){
            HStack(alignment: .center, spacing: 10){
                Image(systemName: selectedType?.iconName ?? AppIcon.QuestionmarkBubbleIcon)
                    .font(.system(size: AppIconSize.Regular))
                    .foregroundColor(Color.brandColorPrimaryTeal)
                AppText(
                    text: selectedType?.title ?? "",
                    fontStyle: .appHeadlinev2,
                )
            }
            
            Spacer()
            
            Image(systemName: AppIcon.ChevronRightCircleIcon)
                .font(.system(size: AppIconSize.Regular))
                .foregroundColor(Color.brandColorPrimaryTeal)
        }

    }
}

#Preview {
    AppAccordionHeader()
}
