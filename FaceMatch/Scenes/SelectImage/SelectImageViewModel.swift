//
//  SelectImageViewModel.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

// MARK: - SelectImageViewModel
final class SelectImageViewModel: ObservableObject {
    
    @Published var animated: Bool
    @Published var showSheet = false
    
    var images = [SelectionImageOption: UIImage]()
    
    private (set) var imageFeatures = [SelectionImageOption: FaceFeaturesInfo]()
    private (set) var azureIds = [SelectionImageOption: FaceModel]()
    private (set) var azureOperations = [SelectionImageOption: CancellableOperation]()
    
    let title: String
    
    private (set)var options = [SelectionImageOption]()
    
    let checkBoxOptions: CheckViewModel
    lazy var coordinator: SelectImageCoordinator = {
        .init(viewModel: self)
    }()
    
    let faceFeatureDetector = FaceFeaturesDetector()
    let imageProcessor = ImageProcessor()
    
    let apiClient = APIClient()
    
    init(animated: Bool = false) {
        self.animated = animated
        title = "Select Image Source".localized
        checkBoxOptions = .init()
        configure()
    }
    
    private func configureCheckBox() {
        checkBoxOptions.isChecked = true
        checkBoxOptions.title = "Analyze emotions".localized
        checkBoxOptions.foregroundColor = .gray
        // Combine could be used for subscbscription: checkBoxOptions.$isChecked.sink
    }
    
    private func configure() {
        options = SelectionImageOption.allCases
        configureCheckBox()
    }
    
    func onAppear() {
        if !animated {
            animated.toggle()
        }
    }
    
    func didSelect(image: UIImage?,
                   for option: SelectionImageOption) {
        debugPrint(#function + " option \(option.localizedTitle) has image \(image.hasValue)" )
        guard let image = image else {
            images.removeValue(forKey: option)
            return
        }
        images[option] = image
        
        var newImage = imageProcessor.convertToMonochrome(image: image) ?? image
        newImage = imageProcessor.compress(image: image)
        images[option] = newImage
        
        azureOperations[option]?.cancel()
        let imageData = newImage.pngData() ?? newImage.jpegData(compressionQuality: 1.0)
        
        //TODO: use as an example image https://www.pngkey.com/png/full/364-3645515_happy-woman-happy-face-woman-png.png
        if let imageData = imageData {
            
            let ciImage = CIImage(data: imageData)
            let faceFeatures = ciImage.flatMap { self.faceFeatureDetector?.detectFaceExpressions(image: $0,
                                                                                                 orientation: nil) } ?? [:]
            debugPrint("Face features \(faceFeatures)")
            let newOp = apiClient.detectUserFrom(imageData: imageData) { [weak self] result in
                guard let self = self, self.azureOperations.removeValue(forKey: option).hasValue else { return }
                debugPrint("Received results for azure operation with option \(option)")
                do {
                    let faceModels = try result.get()
                    //TODO: process faceModels....
                    if let firstModel = faceModels.first {
                        self.azureIds[option] = firstModel
                        debugPrint("!! Received azure first model is happy \(firstModel.faceAttributes.emotion?.happiness ?? 0.0)")
                    } else {
                        self.azureIds.removeValue(forKey: option)
                    }
                } catch {
                    guard !error.isCancelled else { return }
                    //TODO: display error...
                    debugPrint("!! Azure processing error \(error.localizedDescription)")
                }
            }
            debugPrint("Scheduled azure operation for option \(option)")
            azureOperations[option] = newOp
        } else {
            azureOperations.removeValue(forKey: option)
        }
    }
    
    func onDismiss(option: SelectionImageOption) {}
    
    func onTapGesture(option: SelectionImageOption) {
        showSheet = true
    }
}
