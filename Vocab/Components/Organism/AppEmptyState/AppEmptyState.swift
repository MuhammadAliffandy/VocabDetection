import SwiftUI

struct AppEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(Color.brandColorPrimaryTeal.opacity(0.5))
                .padding(.bottom, 8)
            
            AppHeadline(
                title: title,
                subtitle: subtitle,
                titleStyle: .appHeadlinev2,
                subtitleStyle: .appHeadline,
                titleColor: .primary,
                aligment: .center,
                spacing: 12,
                textAlign: .center
            )
        }
        .padding(32)
    }
}

#Preview {
    AppEmptyState(
        icon: "photo.on.rectangle.angled",
        title: "Belum Ada Kosakata",
        subtitle: "Kosakata yang kamu pelajari akan muncul di sini."
    )
}
