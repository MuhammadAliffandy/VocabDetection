//
//  AppAccordionHeader.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct AppAccordionHeader: View {
        
    var selectedType: AppSentenceType? = .exclamation
    
    // 1. Tambah property untuk menerima data status
        var isExpanded: Bool = false
        var hasBeenOpened: Bool = false
        
        // 2. Logic penentuan icon
        private var iconName: String {
            
//            Text(isSuccess ? "Completed" : (isProcessing ? "Loading..." : "Failed"))
            
            isExpanded ? AppIcon.ChevronDownCircleFillIcon : (hasBeenOpened ? AppIcon.ChevronRightCircleFillIcon: AppIcon.ChevronRightCircleIcon)
            
//            if isExpanded {
//                // Ketika terbuka, gunakan panah bawah fill
//                return AppIcon.ChevronDownCircleFillIcon
//            } else if hasBeenOpened {
//                // Ketika tertutup tapi sudah pernah dibuka sebelumnya, gunakan panah kanan fill
//                return AppIcon.ChevronRightCircleFillIcon
//            } else {
//                // Default awal sebelum pernah dibuka, gunakan panah kanan outline biasa
//                return AppIcon.ChevronRightCircleIcon
//            }
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
