import Vision
import CoreML

class YoloVisionService {
    private var visionModel: VNCoreMLModel?
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            let coreMLModel = try yolov8x_oiv7_CoreML(configuration: config)
            self.visionModel = try VNCoreMLModel(for: coreMLModel.model)
        } catch {
            print(error)
        }
    }
    
    // For Static Capture (Photo)
    func detectObjects(in image: CGImage, completion: @escaping ([VNRecognizedObjectObservation]) -> Void) {
        guard let model = visionModel else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                completion([])
                return
            }
            completion(results)
        }
        
        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion([])
        }
    }
    
    // For Real-Time Guidance (Video Frame)
    func detectObjects(in pixelBuffer: CVPixelBuffer, completion: @escaping ([VNRecognizedObjectObservation]) -> Void) {
        guard let model = visionModel else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                completion([])
                return
            }
            completion(results)
        }
        
        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            completion([])
        }
    }
}
