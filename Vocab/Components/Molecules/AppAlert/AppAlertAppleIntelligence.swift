import SwiftUI

struct AppleIntelligenceAlert: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
        
            
            AppHeadline(
                title: "This app best works with\nApple Intelligence turned on" ,
                subtitle: "Izinkan Apple Intelligence menganalisis kosakata Anda untuk menyediakan contoh kalimat kontekstual"
            )
            
            
            AppText(
                text: "Go to Settings > Apple Intelligence & Siri  > turn on Apple Inteligence",
                fontStyle: .appSubheadline,
                textColor:  .textColorSecondaryBlackGrey
            )
            .bold()
            .padding(.top, 4)
            .padding(.bottom, 8)
            
            // MARK: - Buttons Section
            VStack(spacing: AppSpacing.regular) {
            
                
                AppButton(
                    textButton: "Turn On in Settings",
                    textColor: Color.white,
                    fontStyle: .appSubheadlineV2,
                    backgroundColor: Color.blue,
                    action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                        withAnimation { isShowing = false }
                    }
                )
                
                AppButton(
                    textButton: "Keep Service off",
                    textColor: .white,
                    fontStyle: .appSubheadlineV2,
                    backgroundColor: Color.gray,
                    action: {
                        withAnimation { isShowing = false }
                    }
                )
                
                
              
            }
        }
        .padding(28)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 32)
    }
}


#Preview{
    ZStack {
        Color.black.opacity(0.2).ignoresSafeArea()
        AppleIntelligenceAlert(isShowing: .constant(true))
    }
}

