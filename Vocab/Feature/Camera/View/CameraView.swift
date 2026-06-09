import SwiftUI

struct CameraView: View {

    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) var dismiss
    @State private var navigateToLoading = false
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
                
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            navigateToHome = true
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(
                                    Circle().fill(Color.white.opacity(0.85))
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    ViewfinderBrackets()
                        .frame(width: 350, height: 470)
                        .frame(maxHeight: 500)
                    
                    Spacer()
                    
                    Text("Objek terlalu jauh, mendekat")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(Color.black.opacity(0.5))
                        )
                        .padding(.bottom, 70)
                    
                    HStack {
                        Button(action: {
                            
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .frame(width: 60)
                        
                        Spacer()
                        
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
                        
                        Spacer()
                        
                        Color.clear.frame(width: 60)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
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
