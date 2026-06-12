import SwiftUI

struct ViewfinderBrackets: View {

    var isObjectReady: Bool = false
    let iconSize: CGFloat = 50
    
    var body: some View {
        VStack {
            HStack {
                Image(isObjectReady ? AppImageAsset.roundGreenLeftTop : AppImageAsset.roundLeftTop)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                
                Spacer()
                
                Image(isObjectReady ? AppImageAsset.roundGreenRightTop : AppImageAsset.roundRightTop)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }

            Spacer()

            HStack {
                Image(isObjectReady ? AppImageAsset.roundGreenLeftBottom : AppImageAsset.roundLeftBottom)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                
                Spacer()
                
                Image(isObjectReady ? AppImageAsset.roundGreenRightBottom : AppImageAsset.roundRightBottom)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }
        }
    }
}
