import SwiftUI
import PhotosUI

struct CameraView: View {

    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var navigateToLoading = false
    @State private var navigateToHome = false
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
                
                GeometryReader { geo in
                    CameraPreview(session: viewModel.session)
                        .ignoresSafeArea()
                        .accessibilityLabel("Pratinjau Kamera")
                        .accessibilityHint("Gunakan dua jari untuk memperbesar atau memperkecil, ketuk untuk fokus")
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    viewModel.setZoom(factor: currentZoom * value)
                                }
                                .onEnded { value in
                                    currentZoom = viewModel.zoomFactor
                                }
                        )
                        .onTapGesture(coordinateSpace: .local) { location in
                            // Convert tap location to camera focus point
                            let x = location.y / geo.size.height
                            let y = 1.0 - (location.x / geo.size.width)
                            let focusPoint = CGPoint(x: x, y: y)
                            viewModel.setFocus(point: focusPoint)
                            
                            // Optional: Small haptic when focusing
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                }
                
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        
                        AppGlassButton(
                            icon: AppIcon.XmarkIcon,
                            action: {
                                navigateToHome = true
                            },
                            horizontalPadding: AppPadding.areaPadding / 1.7,
                            verticalPadding: AppPadding.areaPadding / 1.7
                        )
                        .accessibilityLabel("Kembali ke Beranda")
                        .accessibilityHint("Tutup kamera dan kembali ke halaman utama")
                    }
                  
                    Spacer()
                
                    ViewfinderBrackets()
                        .frame(maxHeight: 500)
                        .padding(AppPadding.areaPadding)

                    Spacer()
                    
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
                                        viewModel.processGalleryImage(image)
                                    }
                                }
                            }
                            
                            
                            Button(action: {
                                viewModel.capturePhoto()
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
                                viewModel.toggleFlash()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 50, height: 50)
                                    Image(systemName: viewModel.isFlashOn ? AppIcon.BoltIcon : AppIcon.BoltSlashIcon)
                                        .font(.system(size: 24))
                                        .foregroundColor(viewModel.isFlashOn ? .yellow : .white)
                                }
                            }
                            .accessibilityLabel("Lampu Kilat")
                            .accessibilityValue(viewModel.isFlashOn ? "Menyala" : "Mati")
                            .accessibilityHint("Tekan untuk menyalakan atau mematikan lampu kilat")
                        }
                    }
                }
                .padding(AppPadding.areaPadding)
            }
            .onAppear {
                viewModel.checkPermissionsAndStart()
            }
            .onDisappear {
                viewModel.stopSession()
            }
            .onChange(of: viewModel.isProcessingComplete) { _, isComplete in
                if isComplete {
                    navigateToLoading = true
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToLoading) {
                ResultLoadingView(imageData: viewModel.capturedImageData, labels: viewModel.detectedLabels)
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
