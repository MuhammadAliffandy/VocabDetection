//
//  CameraViewModel.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 10/06/26.
//

import SwiftUI
import Vision
import Combine

class CameraViewModel: ObservableObject {
    @Published var detectedObjects: [VNRecognizedObjectObservation] = []
    
    private let yoloService = YOLOVisionService()
    
    func processCameraFrame(_ frame: CVPixelBuffer) {
        yoloService.detectObjects(in: frame) {
            [weak self ] observations in
            
            DispatchQueue.main.async {
                self?.detectedObjects  = observations
            }
        }
    }
    
    
}
