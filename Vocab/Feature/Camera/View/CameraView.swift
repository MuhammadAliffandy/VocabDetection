import SwiftUI
import PhotosUI

struct CameraView: View {

    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) var dismiss
    
    @State private var navigateToLoading = false
    @State private var navigateToHome = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
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
                                navigateToHome = true
                            },
                            horizontalPadding: AppPadding.areaPadding / 1.7,
                            verticalPadding: AppPadding.areaPadding / 1.7,
                            
                        )
                    }
                  
                    
                    Spacer()
                

                    ViewfinderBrackets(isObjectReady: cameraManager.isObjectReady)
                        .frame(maxHeight: 500)
                        .padding(AppPadding.areaPadding)
                        .scaleEffect(cameraManager.bracketScale)
                        .animation(.easeInOut(duration: 0.25), value: cameraManager.bracketScale)

                    Spacer()

                    AppToast(
                        textToast: cameraManager.guidanceMessage
                    )
                    .padding(.bottom,20)
                    
                    HStack(){
                       
                        LazyVGrid(columns: gridColumns, spacing: AppSpacing.medium) {
                            
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: AppIcon.PhotoOnRectangleIcon)
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                            .onChange(of: selectedPhotoItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        cameraManager.processGalleryImage(image)
                                    }
                                }
                            }
                            
                            
                            Button(action: {
                                cameraManager.capturePhoto()
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
            .onChange(of: cameraManager.isProcessingComplete) { _, isComplete in
                if isComplete {
                    navigateToLoading = true
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLoading) {
                ResultLoadingView(imageData: cameraManager.capturedImageData, labels: cameraManager.detectedLabels)
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
