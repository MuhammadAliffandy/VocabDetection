//
//  CustomCameraView.swift
//  Vocab
//
//  Created by Hatami Sugandi on 09/06/26.
//

import SwiftUI

struct CustomCameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Memanggil file CameraPreview.swift
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color.white.opacity(0.85))
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)
                
                Spacer()
                
                // Memanggil file ViewfinderBrackets.swift
                ViewfinderBrackets()
                    .frame(width: 280, height: 380)
                
                Spacer()
                
                Text("Objek terlalu jauh, mendekat")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(Color.black.opacity(0.5))
                    )
                    .padding(.bottom, 30)
                
                HStack {
                    Button(action: {
                        // Aksi buka galeri
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .frame(width: 60)
                    
                    Spacer()
                    
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
                    
                    Spacer()
                    
                    Color.clear.frame(width: 60)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.checkPermissionsAndStart()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .navigationBarHidden(true)
    }
}
