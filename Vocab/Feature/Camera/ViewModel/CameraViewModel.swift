import SwiftUI
import Vision
import Combine

class CameraViewModel: ObservableObject {
    @Published var detectedObjects: [VNRecognizedObjectObservation] = []
    
    private let yoloService = YoloVisionService()
    
    func processCameraFrame(_ frame: CVPixelBuffer) {
        yoloService.detectObjects(in: frame) {
            [weak self ] observations in
            
            DispatchQueue.main.async {
                self?.detectedObjects = observations
            }
        }
    }
}
