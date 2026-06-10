import AVFoundation
import UIKit
import Combine
import SwiftUI
import Vision

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureVideoDataOutput()
    
    private let yoloService = YOLOVisionService()
    
    private let targetLabel = "person"
    private let confidenceThreshold: Float = 0.70
    
    @Published var detectedObjects: [VNRecognizedObjectObservation] = []
    @Published var isProcessingComplete: Bool = false
    
    @Published var guidanceMessage: String = "Mencari objek..."
    @Published var bracketScale: CGFloat = 1.0
    
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
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
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
            
            // Find the single largest object based on bounding box area
            let largestObject = observations.max(by: { a, b in
                let areaA = a.boundingBox.width * a.boundingBox.height
                let areaB = b.boundingBox.width * b.boundingBox.height
                return areaA < areaB
            })
            
            DispatchQueue.main.async {
                if let target = largestObject {
                    self.detectedObjects = [target]
                    
                    let label = target.labels.first?.identifier ?? "Unknown"
                    print("Captured Prominent Object: \(label)")
                } else {
                    self.detectedObjects = []
                }
                self.isProcessingComplete = true
            }
        }
    }
}

// MARK: - Video Data Output Delegate (Real-Time - Focus on Largest Object)
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        yoloService.detectObjects(in: pixelBuffer) { [weak self] observations in
            guard let self = self else { return }
            
            // Find the single largest object based on bounding box area
            let largestObject = observations.max(by: { a, b in
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
                        self.guidanceMessage = "Dekatkan Kamera ke \(objectLabel)"
                        self.bracketScale = 0.8
                    } else if objectWidth > 0.68 {
                        self.guidanceMessage = "Jauhkan Kamera dari \(objectLabel)"
                        self.bracketScale = 1.2
                    } else {
                        self.guidanceMessage = "\(objectLabel) Terdeteksi! Silakan Ambil Foto"
                        self.bracketScale = 1.0
                    }
                } else {
                    self.detectedObjects = []
                    self.guidanceMessage = "Posisikan objek di dalam kotak"
                    self.bracketScale = 1.0
                }
            }
        }
    }
}
