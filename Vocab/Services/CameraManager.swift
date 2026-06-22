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
        guard session.inputs.isEmpty else {
            DispatchQueue.global(qos: .background).async {
                if !self.session.isRunning {
                    self.session.startRunning()
                }
            }
            return
        }
        
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
        guard let _ = image.cgImage else { return }
        
        autoreleasepool {
            guard let optimizedData = self.downsampleImage(image) else { return }
            
            DispatchQueue.main.async {
                self.isProcessingComplete = false
                self.detectedLabels = []
                self.capturedImageData = optimizedData
                
                self.isProcessingComplete = true
            }
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.isProcessingComplete = false
            self.capturedImageData = nil
            self.detectedLabels = []
        }
    }
    
    private func downsampleImage(_ image: UIImage, maxDimension: CGFloat = 800) -> Data? {
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        if ratio >= 1.0 {
            return image.jpegData(compressionQuality: 0.7)
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage.jpegData(compressionQuality: 0.7)
    }
}

// MARK: - Photo Capture Delegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let originalImage = UIImage(data: data) else {
            return
        }
        
        autoreleasepool {
            guard let optimizedData = self.downsampleImage(originalImage) else { return }
            
            DispatchQueue.main.async {
                self.capturedImageData = optimizedData
                self.isProcessingComplete = true
            }
        }
    }
}
