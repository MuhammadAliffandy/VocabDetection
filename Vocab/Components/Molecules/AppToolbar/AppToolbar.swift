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
    var onEllipsisTap: () -> Void;
    
    var body: some View {
        HStack(spacing: 16){
            AppWrapButton(
                action: {
                    isMagnifyClicked.toggle()
                    onMagnifyingTap(isMagnifyClicked)
                }
            ){
                Image(systemName: isMagnifyClicked ? AppIcon.XmarkIcon :  AppIcon.MagnifyingGlassIcon )
                    .font(.system(size: AppIconSize.Regular))
                    .foregroundColor(Color.black)
                    .bold()
            }
            
            
            if !isMagnifyClicked {
                AppWrapButton(
                    action: onEllipsisTap
                ){
                    Image(systemName: AppIcon.EllipsisIcon)
                        .font(.system(size: AppIconSize.Regular))
                        .foregroundColor(Color.black)
                        .bold()
                }
            }
        }
        .padding(AppPadding.areaPadding)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: .infinity))
    }
}

#Preview {
    AppToolbar(
        onMagnifyingTap: {
            isClicked in
            print(isClicked
            )
        } , onEllipsisTap: {}
    )
}
