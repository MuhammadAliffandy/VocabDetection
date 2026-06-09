//
//  AppTipWrap.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI


struct TriangleDown: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Draw a triangle pointing downwards
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}



// ==========================================
// 2. THE TOOLTIP MODIFIER (THE WRAPPER)
// ==========================================
struct TooltipModifier: ViewModifier {
    var text: String
    var isVisible: Bool
    var y: CGFloat = -95
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if isVisible {
                        VStack(spacing: 0) {
                            
                            // ==========================================
                            // THE BUBBLE BOX
                            // ==========================================
                            Text(text)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: true, vertical: true)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                            
                            // The Triangle Tail
                            TriangleDown()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: 20, height: 10)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                        }
                        .offset(y: y)
                        .transition(.scale.combined(with: .opacity))
                        // 🌟 THE FIX: Force this bubble to the front!
                        .zIndex(1)
                    }
                }
                , alignment: .top
            )
    }
}


extension View {
    func appTooltip(_ text: String, isVisible: Bool = true , y:CGFloat = -95) -> some View {
        self.modifier(TooltipModifier(text: text, isVisible: isVisible , y: y))
    }
}
