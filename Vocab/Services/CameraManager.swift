import AVFoundation
import UIKit
import Combine
import SwiftUI
import Vision

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    
    @Published var detectedLabels: [String] = []
    @Published var capturedImageData: Data?
    
    @Published var isProcessingComplete: Bool = false
    
    // Default messages since we don't have real-time guidance anymore
    @Published var guidanceMessage: String = "Silakan Ambil Foto"
    @Published var bracketScale: CGFloat = 1.0
    @Published var isObjectReady: Bool = true
    
    @Published var isFlashOn: Bool = false
    @Published var zoomFactor: CGFloat = 1.0
    
    func checkPermissionsAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { self?.setupCamera() }
                }
            }
        default:
            break
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.stopRunning()
            }
        }
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = isFlashOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
            }
        }
    }
    
    func setZoom(factor: CGFloat) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        do {
            try device.lockForConfiguration()
            let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 5.0)
            device.videoZoomFactor = max(1.0, min(factor, maxZoom))
            device.unlockForConfiguration()
            DispatchQueue.main.async {
                self.zoomFactor = device.videoZoomFactor
            }
        } catch {
        }
    }
    
    func capturePhoto() {
        DispatchQueue.main.async {
            self.isProcessingComplete = false
            self.detectedLabels = []
            self.capturedImageData = nil
        }
        
        let settings = AVCapturePhotoSettings()
        if photoOutput.supportedFlashModes.contains(isFlashOn ? .on : .off) {
            settings.flashMode = isFlashOn ? .on : .off
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func processGalleryImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        DispatchQueue.main.async {
            self.isProcessingComplete = false
            self.detectedLabels = []
            // Menggunakan JPEG data agar tidak terlalu besar
            self.capturedImageData = image.jpegData(compressionQuality: 0.8)
            
            // Navigate directly; ResultLoadingView will handle FastVLM detection
            self.isProcessingComplete = true
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.isProcessingComplete = false
            self.capturedImageData = nil
            self.detectedLabels = []
        }
    }
}

// MARK: - Photo Capture Delegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImageData = data
            // Navigate directly; ResultLoadingView will handle FastVLM detection
            self.isProcessingComplete = true
        }
    }
}
