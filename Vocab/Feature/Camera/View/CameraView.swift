import SwiftUI
import PhotosUI

struct CameraView: View {

    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) var dismiss
    
    @State private var navigateToLoading = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var currentZoom: CGFloat = 1.0
    
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
                    .accessibilityLabel("Pratinjau Kamera")
                    .accessibilityHint("Gunakan dua jari untuk memperbesar atau memperkecil")
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                cameraManager.setZoom(factor: currentZoom * value)
                            }
                            .onEnded { value in
                                currentZoom = cameraManager.zoomFactor
                            }
                    )
                
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        
                        AppGlassButton(
                            icon: AppIcon.XmarkIcon,
                            action: {
                                dismiss()
                            },
                            horizontalPadding: AppPadding.areaPadding / 1.7,
                            verticalPadding: AppPadding.areaPadding / 1.7
                        )
                        .accessibilityLabel("Kembali ke Beranda")
                        .accessibilityHint("Tutup kamera dan kembali ke halaman utama")
                    }
                  
                    
                    Spacer()
                

                    ViewfinderBrackets(isObjectReady: cameraManager.isObjectReady)
                        .frame(maxHeight: 500)
                        .padding(AppPadding.areaPadding)
                        .scaleEffect(cameraManager.bracketScale)
                        .animation(.easeInOut(duration: 0.25), value: cameraManager.bracketScale)

                    Spacer()

                    // Removed toast as requested
                    
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
                            .accessibilityLabel("Galeri Foto")
                            .accessibilityHint("Pilih foto dari galeri untuk dideteksi kosakatanya")
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
                            .accessibilityLabel("Ambil Foto")
                            .accessibilityHint("Ambil foto objek yang ada di pratinjau kamera")
                            
                            Button(action: {
                                cameraManager.toggleFlash()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: cameraManager.isFlashOn ? AppIcon.BoltIcon : AppIcon.BoltSlashIcon)
                                        .font(.system(size: 24))
                                        .foregroundColor(cameraManager.isFlashOn ? .yellow : .white)
                                }
                            }
                            .accessibilityLabel("Lampu Kilat")
                            .accessibilityValue(cameraManager.isFlashOn ? "Menyala" : "Mati")
                            .accessibilityHint("Tekan untuk menyalakan atau mematikan lampu kilat")
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
            .toolbar(.hidden, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToLoading) {
                ResultLoadingView(imageData: cameraManager.capturedImageData, labels: cameraManager.detectedLabels)
            }
        }
    }
}

#Preview {
    CameraView()
}
