//
//  AppToolbar.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 08/06/26.
//

import SwiftUI

struct AppToolbar: View {
    
    @State private var isMagnifyClicked :Bool = false
    
    var onMagnifyingTap: (Bool) -> Void;
    var horizontalPadding: CGFloat = AppPadding.areaPadding * 1.2
    var verticalPadding: CGFloat = AppPadding.areaPadding
    
    var body: some View {
        AppGlassButton(
            icon: isMagnifyClicked ? AppIcon.XmarkIcon :  AppIcon.MagnifyingGlassIcon ,
            action: {
                isMagnifyClicked.toggle()
                onMagnifyingTap(isMagnifyClicked)
            },
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            
            
        )


    }
}

#Preview {
    AppToolbar(
        onMagnifyingTap: {
            isClicked in
        } ,

    )
}
