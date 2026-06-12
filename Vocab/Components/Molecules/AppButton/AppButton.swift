//
//  AppButton.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//
import SwiftUI


struct AppButton: View {
    
    var textButton: String = "Text Default"
    var textColor: Color = .black
    var fontStyle: Font = .appHeadlinev2
    var backgroundColor: Color = .blue
    var action: () -> Void = {}
    
    
    var body: some View{
        AppWrapButton(
            action: action
        ){
            AppText(
                text: textButton,
                fontStyle: fontStyle,
                textColor: textColor,
            )
            .multilineTextAlignment(.center)
              
        }
        .buttonStyle(.appPrimary(color: backgroundColor))
    }
}



#Preview {
    AppButton(
        textButton: "Text example",
        backgroundColor: Color.brandColorPrimaryTeal,
        action: {
            // add your logic on here
        }
    )
    
    AppButton(
        textButton: "Keep Apple Intelligence Service off",
        textColor: Color.white,
        backgroundColor: Color.blue,
        action: {
            // add your logic on here
        }
    )
    
    AppButton(
        textButton: "Text example",
        textColor: .white,
        backgroundColor: Color.gray,
        action: {
            // add your logic on here
        }
    )
    
}
