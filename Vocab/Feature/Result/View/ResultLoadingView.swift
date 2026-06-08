import SwiftUI

struct ResultLoadingView: View {
    
    @State private var navigateToResult = false
    
    var body: some View {
        ZStack {
            
            Image(AppImageAsset.dummyImage)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .blur(radius: 6)
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
            
                ProgressView()
                    .controlSize(.large)
                
                Spacer()
                
                AppHeadline(
                    title: "Memindai kosa kata...",
                    subtitle: "Memindai kata dari gambar yang sudah kamu ambil",
                    titleStyle: .appTitle,
                    subtitleStyle: .appHeadline,
                    aligment: .leading,
                    isFullWidth: true
                )
                .padding(.bottom, 40)
                .padding(.top, AppPadding.areaPadding)
                .padding(.horizontal, AppPadding.areaPadding)
                .background(.white)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                navigateToResult = true
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView()
        }
    }
}

#Preview {
    NavigationStack {
        ResultLoadingView()
    }
}
