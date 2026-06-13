//
//  AppAccordionHeader.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppAccordionHeader: View {
        
    var selectedType: AppSentenceType? = .exclamation
    
        var isExpanded: Bool = false
        var hasBeenOpened: Bool = false
        
        private var iconName: String {
        
            
            isExpanded ? AppIcon.ChevronDownCircleFillIcon : (hasBeenOpened ? AppIcon.ChevronRightCircleFillIcon: AppIcon.ChevronRightCircleIcon)
            

        }

    var body: some View {
        HStack(alignment: .center){
            HStack(alignment: .center, spacing: 10){
                Image(systemName: selectedType?.iconName ?? AppIcon.QuestionmarkBubbleIcon)
                    .font(.system(size: AppIconSize.Regular))
                    .foregroundColor(Color.brandColorPrimaryTeal)
                AppText(
                    text: selectedType?.title ?? "",
                    fontStyle: .appHeadlinev2,
                    textColor: .primary,
                )
            }
            
            Spacer()
            
            Image(systemName: iconName)
                .font(.system(size: AppIconSize.Regular))
                .foregroundColor(Color.brandColorPrimaryTeal)
        }

    }
}

#Preview {
    AppAccordionHeader(
        selectedType: .statement
    )
//    AppAccordionHeader(
//        selectedType: .question
//    )
//    AppAccordionHeader(
//        selectedType: .command
//    )
//    AppAccordionHeader(
//        selectedType: .exclamation
//    )
    
}
