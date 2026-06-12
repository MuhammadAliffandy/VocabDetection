//
//  AppCameraButton.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//


import SwiftUI

struct AppCameraButton: View {
    
    var action: () -> Void
    
    
    var body: some View {
        AppWrapButton(action: action) {
            Image(systemName: AppIcon.CameraApertureIcon)
                .font(.system(size: AppIconSize.Large))
                .foregroundColor(Color.brandColorPrimaryTeal)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: .infinity))
                .AppShadowCamera()
        }
    }
}


#Preview {
    
    AppCameraButton(action : {})
    
//    AppCameraButton(action : {})
//        .appTooltip("Tekan Icon\nuntuk membuka\nkamera", isVisible: true)
}
