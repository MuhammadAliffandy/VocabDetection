//
//  CameraView.swift
//  Vocab
//
//  Created by Muhammad Aliffandy on 06/06/26.
//

import SwiftUI
import UIKit

// ==========================================
// THE CAMERA WRAPPER COMPONENT
// ==========================================
struct AppCameraPicker: UIViewControllerRepresentable {
    
    // This will hold the photo after the user takes it
    @Binding var selectedImage: UIImage?
    
    // To dismiss the camera view automatically
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // Force the picker to open the actual camera, not the photo gallery
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // ==========================================
    // THE COORDINATOR (Handles the take/cancel button)
    // ==========================================
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: AppCameraPicker
        
        init(_ parent: AppCameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            // Close the camera after taking the photo
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Close the camera if the user taps "Cancel"
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}



