
//

import SwiftUI

struct AppAccordion<Header: View, Footer: View>: View {
    
    @State private var isExpanded: Bool = false
    @State private var hasBeenOpened: Bool = false
    
    @ViewBuilder let header: (Bool, Bool) -> Header
    @ViewBuilder let footer: Footer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
        
            Button(action: {

                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                    if isExpanded {
                        hasBeenOpened = true
                    }
                }
            }) {
                header(isExpanded, hasBeenOpened)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                footer
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        )
                    )
            }
        }
        .clipped()
    }
}
