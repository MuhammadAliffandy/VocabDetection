//
//  AppFlowLayout.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 11/06/26.
//

import SwiftUI

// A custom layout that wraps its subviews to the next line
// when the current line runs out of horizontal space.
struct AppFlowLayout: Layout {
    var spacing: CGFloat = 6
    var alignment: HorizontalAlignment = .center
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing, alignment: alignment)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> Void {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing, alignment: alignment)
        for (index, subview) in subviews.enumerated() {
            let point = result.points[index]
            subview.place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }
    
    // Helper struct to calculate coordinates and total size
    struct FlowResult {
        var size: CGSize = .zero
        var points: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat, alignment: HorizontalAlignment) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            var rowStartIndex = 0
            var tempPoints: [CGPoint] = []
            var tempSizes: [CGSize] = []
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                tempSizes.append(size)
                
                if currentX + size.width > maxWidth, currentX > 0 {
                    // Finish current row
                    let rowWidth = currentX - spacing
                    let offsetX: CGFloat
                    if alignment == .leading {
                        offsetX = 0
                    } else if alignment == .trailing {
                        offsetX = maxWidth - rowWidth
                    } else {
                        offsetX = (maxWidth - rowWidth) / 2
                    }
                    
                    for i in rowStartIndex..<index {
                        tempPoints[i].x += max(0, offsetX)
                        // Vertically center
                        tempPoints[i].y += (lineHeight - tempSizes[i].height) / 2
                    }
                    
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                    rowStartIndex = index
                }
                
                tempPoints.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            // Finish last row
            if currentX > 0 {
                let rowWidth = currentX - spacing
                let offsetX: CGFloat
                if alignment == .leading {
                    offsetX = 0
                } else if alignment == .trailing {
                    offsetX = maxWidth - rowWidth
                } else {
                    offsetX = (maxWidth - rowWidth) / 2
                }
                
                for i in rowStartIndex..<subviews.count {
                    tempPoints[i].x += max(0, offsetX)
                    // Vertically center
                    tempPoints[i].y += (lineHeight - tempSizes[i].height) / 2
                }
            }
            
            self.points = tempPoints
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
