import SwiftUI

struct AppCongratsModal: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let onSelesai: () -> Void
    let onCobaLagi: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 16)
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(iconColor)
            
            AppHeadline(
                title: title,
                subtitle: subtitle,
                titleStyle: .appHeadlinev2,
                subtitleStyle: .appHeadline,
                titleColor: .primary,
                aligment: .center,
                spacing: 8,
                textAlign: .center
            )
            
            Spacer()
            
            VStack(spacing: 12) {
                AppButton(
                    textButton: "Selesai",
                    textColor: .white,
                    backgroundColor: .brandColorPrimaryTeal,
                    action: onSelesai
                )
                
                Button(action: onCobaLagi) {
                    Text("Coba Lagi")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.brandColorPrimaryTeal)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 32)
        }
        .padding(32)
        .presentationDetents([.fraction(0.5)])
        .presentationDragIndicator(.visible)
    }
}
