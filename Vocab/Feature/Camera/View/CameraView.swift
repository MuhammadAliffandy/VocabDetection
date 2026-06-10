import SwiftUI

struct CameraView: View {

    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) var dismiss
    
    @State private var navigateToLoading = false
    @State private var navigateToHome = false
    
    let gridColumns = [
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.black.ignoresSafeArea()
                
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        
                        AppGlassButton(
                            icon: AppIcon.XmarkIcon,
                            action: {
                                print("Back tapped")
                            },
                            horizontalPadding: AppPadding.areaPadding / 1.7,
                            verticalPadding: AppPadding.areaPadding / 1.7,
                            
                        )
                    }
                  
                    
                    Spacer()
                

                    ViewfinderBrackets()
                        .frame(maxHeight: 500)
                        .padding(AppPadding.areaPadding)
                        .scaleEffect(cameraManager.bracketScale)
                        .animation(.easeInOut(duration: 0.25), value: cameraManager.bracketScale)

                    Spacer()

                    AppToast(
                        textToast: cameraManager.guidanceMessage
                    )
                    
                    HStack(){
                       
                        LazyVGrid(columns: gridColumns, spacing: AppSpacing.medium) {
                            
                            AppWrapButton(action: {
                                
                            }) {
                                Image(systemName: AppIcon.PhotoOnRectangleIcon)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            
                            
                            Button(action: {
                                cameraManager.capturePhoto()
                                navigateToLoading = true
                            }) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                        .frame(width: 70, height: 70)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 56, height: 56)
                                }
                            }
                        }
                    }
                }
                .padding(AppPadding.areaPadding)
            }
            .onAppear {
                cameraManager.checkPermissionsAndStart()
            }
            .onDisappear {
                cameraManager.stopSession()
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLoading) {
                ResultLoadingView()
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        }
    }
}

#Preview {
    CameraView()
}
