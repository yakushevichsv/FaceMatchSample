//
//  CameraView.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var prefferedSourceType: UIImagePickerController.SourceType = Self.adjustOnNeed(sourceType: .camera) {
        didSet {
            guard oldValue != prefferedSourceType else {
                return
            }
            prefferedSourceType = Self.adjustOnNeed(sourceType: oldValue)
        }
    }
    
    @Binding var selectedImage: UIImage?
    
    static func adjustOnNeed(sourceType prefferedSourceType: UIImagePickerController.SourceType) -> UIImagePickerController.SourceType {
        if UIImagePickerController.isSourceTypeAvailable(prefferedSourceType) {
            return prefferedSourceType
        } else {
            let newSourceTypeRaw = (prefferedSourceType.rawValue + 1)/(UIImagePickerController.SourceType.savedPhotosAlbum.rawValue + 1) //all cases...
            
            let newSourceType = UIImagePickerController.SourceType(rawValue: newSourceTypeRaw) ?? .photoLibrary
            
            assert(UIImagePickerController.isSourceTypeAvailable(newSourceType))
            return newSourceType
        }
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = prefferedSourceType
        imagePicker.delegate = context.coordinator
        
        /* TODO: how to handle that?
        if UIDevice.current.userInterfaceIdiom == .pad {
            imagePicker.modalPresentationStyle = .popover
            imagePicker.popoverPresentationController?.sourceView = vc.view
            imagePicker.popoverPresentationController?.sourceRect = view.frame
        } */
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        private func dismissPicker() {
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            dismissPicker()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismissPicker()
        }
    }
}
