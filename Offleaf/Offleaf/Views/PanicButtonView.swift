//
//  PanicButtonView.swift
//  Offleaf
//
//  Created by Assistant on 10/16/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct PanicButtonView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingRelapsing = false
    @State private var showingRelapsed = false
    @AppStorage("userPromiseImage") private var userPromiseImageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.05),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("I Need Help")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4))
                    
                    Spacer()
                    
                    // Balance spacing
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 60)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Promise Image/Picker
                        VStack(spacing: 20) {
                            if let imageData = userPromiseImageData,
                               let uiImage = UIImage(data: imageData) {
                                // Show saved image
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 320, height: 320)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .overlay(alignment: .bottom) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("YOU MADE A")
                                                Text("PROMISE TO")
                                                Text("YOURSELF")
                                            }
                                            .font(.system(size: 22, weight: .heavy))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 18)
                                            .background(
                                                LinearGradient(
                                                    colors: [
                                                        Color.black.opacity(0.85),
                                                        Color.black.opacity(0.2)
                                                    ],
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                        }

                                    // Change photo button
                                    PhotosPicker(selection: $selectedItem) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .frame(width: 36, height: 36)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                            .padding(12)
                                    }
                                }
                            } else {
                                // Camera button as primary action
                                Button(action: {
                                    // Check if camera is available
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        showingCamera = true
                                    } else {
                                        // Fallback to photo picker if camera not available (simulator)
                                        showingPhotoPicker = true
                                    }
                                }) {
                                    VStack(spacing: 16) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 48))
                                            .foregroundColor(.white.opacity(0.5))
                                        
                                        VStack(spacing: 8) {
                                            Text("Add Your Promise")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Text("Take a photo of who or what\nyou're staying strong for")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.5))
                                                .multilineTextAlignment(.center)
                                            
                                        }
                                    }
                                    .frame(width: 320, height: 320)
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.white.opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.top, 32)
                        .onChange(of: selectedItem) { oldItem, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    await MainActor.run {
                                        userPromiseImageData = data
                                        selectedImage = UIImage(data: data)
                                    }
                                }
                            }
                        }
                        
                        // Side effects section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Remember the costs:")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            
                            VStack(alignment: .leading, spacing: 16) {
                                SideEffectRow(
                                    icon: "brain.head.profile",
                                    title: "MENTAL FOG",
                                    color: Color(red: 0.9, green: 0.5, blue: 0.2)
                                )
                                
                                SideEffectRow(
                                    icon: "lungs.fill",
                                    title: "LUNG DAMAGE",
                                    color: Color(red: 0.8, green: 0.3, blue: 0.3)
                                )
                                
                                SideEffectRow(
                                    icon: "dollarsign.circle.fill",
                                    title: "WASTED MONEY",
                                    color: Color(red: 0.7, green: 0.7, blue: 0.3)
                                )
                                
                                SideEffectRow(
                                    icon: "heart.slash.fill",
                                    title: "LOST MOTIVATION",
                                    color: Color(red: 0.9, green: 0.4, blue: 0.4)
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Bottom buttons
                        VStack(spacing: 16) {
                            // I Relapsed button
                            Button(action: {
                                showingRelapsed = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("I Relapsed")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(Color(red: 1, green: 0.6, blue: 0.6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color(red: 0.2, green: 0.05, blue: 0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 28)
                                                .stroke(Color(red: 0.4, green: 0.15, blue: 0.15), lineWidth: 1)
                                        )
                                )
                            }
                            
                            // I'm thinking of relapsing button (prominent)
                            Button(action: {
                                showingRelapsing = true
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("I'm thinking of relapsing")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.9, green: 0.3, blue: 0.3),
                                            Color(red: 0.7, green: 0.2, blue: 0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(color: Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.3), radius: 10, y: 4)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingRelapsing) {
            ThinkingOfRelapsingView()
        }
        .fullScreenCover(isPresented: $showingRelapsed) {
            RelapsedView(dismissAll: {
                // Dismiss both RelapsedView and PanicButtonView
                showingRelapsed = false
                dismiss()
            })
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(image: $selectedImage) { image in
                if let image = image {
                    selectedImage = image
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        userPromiseImageData = imageData
                    }
                }
            }
            .preferredColorScheme(.dark)
            .statusBarHidden(true)
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotosPicker(selection: $selectedItem) {
                Text("Choose from Library")
            }
            .presentationDetents([.medium])
        }
    }
}

struct SideEffectRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

// Camera View for capturing promise photos
struct CameraView: View {
    @Binding var image: UIImage?
    let onCapture: (UIImage?) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showingImagePicker = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            CameraPickerView(image: $image, onCapture: onCapture, dismiss: dismiss)
                .ignoresSafeArea()
        }
    }
}

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let onCapture: (UIImage?) -> Void
    let dismiss: DismissAction
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraDevice = .front // Start with front camera for selfies
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = true
        picker.modalPresentationStyle = .overFullScreen
        
        // Customize appearance to minimize white bars
        picker.navigationBar.barStyle = .black
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.barTintColor = .black
        picker.navigationBar.tintColor = .white
        picker.view.backgroundColor = .black
        
        // Set the camera overlay to fill the screen
        picker.cameraViewTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
                parent.onCapture(image)
            } else if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onCapture(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PanicButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PanicButtonView()
    }
}
