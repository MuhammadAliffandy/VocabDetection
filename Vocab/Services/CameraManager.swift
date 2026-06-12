import AVFoundation
import UIKit
import Combine
import SwiftUI
import Vision

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureVideoDataOutput()
    
    private let yoloService = YoloVisionService()
    
    private let targetLabel = "person"
    private let confidenceThreshold: Float = 0.45
    
    @Published var detectedObjects: [VNRecognizedObjectObservation] = []
    @Published var detectedLabels: [String] = []
    @Published var capturedImageData: Data?
    
    @Published var isProcessingComplete: Bool = false
    
    @Published var guidanceMessage: String = "arahkan kamera ke satu benda yang ingin anda foto"
    @Published var bracketScale: CGFloat = 1.0
    @Published var isObjectReady: Bool = false
    
    private var lastDetectionTime = Date()
    
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
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
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
    
    func capturePhoto() {
        DispatchQueue.main.async {
            self.isProcessingComplete = false
            self.detectedObjects = []
            self.detectedLabels = []
            self.capturedImageData = nil
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func processGalleryImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        DispatchQueue.main.async {
            self.isProcessingComplete = false
            self.detectedObjects = []
            self.detectedLabels = []
            // Menggunakan JPEG data agar tidak terlalu besar
            self.capturedImageData = image.jpegData(compressionQuality: 0.8)
        }
        
        yoloService.detectObjects(in: cgImage) { [weak self] observations in
            guard let self = self else { return }
            
            let validObservations = observations.filter { ($0.labels.first?.confidence ?? 0.0) >= self.confidenceThreshold }
            let largestObject = validObservations.max(by: { a, b in
                let areaA = a.boundingBox.width * a.boundingBox.height
                let areaB = b.boundingBox.width * b.boundingBox.height
                return areaA < areaB
            })
            
            DispatchQueue.main.async {
                if let target = largestObject {
                    self.detectedObjects = [target]
                    let label = target.labels.first?.identifier ?? "Unknown"
                    self.detectedLabels = [label]
                    print("Gallery Object: \(label)")
                } else {
                    self.detectedObjects = []
                    self.detectedLabels = []
                }
                self.isProcessingComplete = true
            }
        }
    }
}

// MARK: - Photo Capture Delegate (Static - Focus on Largest Object)
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data),
              let cgImage = image.cgImage else {
            return
        }
        
        yoloService.detectObjects(in: cgImage) { [weak self] observations in
            guard let self = self else { return }
            
            let validObservations = observations.filter { ($0.labels.first?.confidence ?? 0.0) >= self.confidenceThreshold }
            let largestObject = validObservations.max(by: { a, b in
                let areaA = a.boundingBox.width * a.boundingBox.height
                let areaB = b.boundingBox.width * b.boundingBox.height
                return areaA < areaB
            })
            
            DispatchQueue.main.async {
                self.capturedImageData = data
                if let target = largestObject {
                    self.detectedObjects = [target]
                    
                    let label = target.labels.first?.identifier ?? "Unknown"
                    self.detectedLabels = [label]
                    print("Captured Prominent Object: \(label)")
                } else {
                    self.detectedObjects = []
                    self.detectedLabels = []
                }
                self.isProcessingComplete = true
            }
        }
    }
}

// MARK: - Video Data Output Delegate (Real-Time - Focus on Largest Object)
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let now = Date()
        if now.timeIntervalSince(lastDetectionTime) < 0.2 { return }
        lastDetectionTime = now
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        yoloService.detectObjects(in: pixelBuffer) { [weak self] observations in
            guard let self = self else { return }
            
            let validObservations = observations.filter { ($0.labels.first?.confidence ?? 0.0) >= self.confidenceThreshold }
            let largestObject = validObservations.max(by: { a, b in
                let areaA = a.boundingBox.width * a.boundingBox.height
                let areaB = b.boundingBox.width * b.boundingBox.height
                return areaA < areaB
            })
            
            DispatchQueue.main.async {
                if let target = largestObject {
                    self.detectedObjects = [target]
                    
                    // Use the width of the most prominent object for distance guidance
                    let objectWidth = target.boundingBox.width
                    let objectLabel = target.labels.first?.identifier ?? "Object"
                    
                    if objectWidth < 0.38 {
                        self.guidanceMessage = "Benda terlalu jauh, mendekat ke benda"
                        self.bracketScale = 0.8
                        self.isObjectReady = false
                    } else if objectWidth > 0.68 {
                        self.guidanceMessage = "Camera terlalu dekat, sedikit menjauh"
                        self.bracketScale = 1.2
                        self.isObjectReady = false
                    } else {
                        self.guidanceMessage = "Objek Terdeteksi! Silakan Ambil Foto"
                        self.bracketScale = 1.0
                        if !self.isObjectReady {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        }
                        self.isObjectReady = true
                    }
                } else {
                    self.detectedObjects = []
                    self.guidanceMessage = "Posisikan benda di dalam kotak kamera"
                    self.bracketScale = 1.0
                    self.isObjectReady = false
                }
            }
        }
    }
}
