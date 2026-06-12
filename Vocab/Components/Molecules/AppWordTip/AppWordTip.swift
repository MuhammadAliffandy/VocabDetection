//
//  AppWordTip.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Start at the left edge
        path.move(to: CGPoint(x: 0, y: 0))
        // Draw straight to the right edge
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}


struct AppWordTip: View {
    var text: String
    var tooltipText: String
    var textStyle: Font = .appHeadline
    var isPressed: Bool = false
    var isVocab: Bool = false
    
    var body: some View {
        AppText(
            text: text,
            fontStyle: textStyle ,
            textColor: Color.brandColorPrimaryTeal
        )
        .appTooltip(tooltipText, isVisible: isPressed , y: -55)
        .overlay(
            Group {
                if isVocab {
                    Line()
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 3,
                                lineCap: .round,
                                dash: [5, 6]
                            )
                        )
                        .foregroundColor(Color.brandColorPrimaryTeal)
                        .frame(height: 1)
                }
            }

            , alignment: .bottom
        )
        
    }
}


#Preview {
    
    VStack{
        AppWordTip(
            text: "word" ,
            tooltipText: "tooltip text",
            textStyle: .appHeadlinev2,
            isPressed: true,
            isVocab: true
          
        )
        
        
        AppWordTip(
            text: "word" ,
            tooltipText: "tooltip text"
        )
    }
    .padding(100)
    .background(Color.red)

    
}
