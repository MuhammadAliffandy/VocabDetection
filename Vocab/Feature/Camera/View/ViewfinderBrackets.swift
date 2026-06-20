import SwiftUI

struct ViewfinderBrackets: View {
    let iconSize: CGFloat = 50
    
    var body: some View {
        VStack {
            HStack {
                Image(AppImageAsset.roundLeftTop)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                
                Spacer()
                
                Image(AppImageAsset.roundRightTop)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }

            Spacer()

            HStack {
                Image(AppImageAsset.roundLeftBottom)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                
                Spacer()
                
                Image(AppImageAsset.roundRightBottom)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }
        }
    }
}
