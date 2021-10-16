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
    @Published var displayAlert = false
    var alertMessage: String?
    
    var images = [SelectionImageOption: UIImage]()
    
    private (set) var imageFeatures = [SelectionImageOption: FaceFeaturesInfo]()
    private (set) var azureIds = [SelectionImageOption: FaceModel]()
    private (set) var azureOperations = [SelectionImageOption: CancellableOperation]()
    private (set) var identityOperation: CancellableOperation?
    
    let options: [SelectionImageOption] = SelectionImageOption.allCases
    
    let checkBoxOptions: CheckViewModel
    
    let coordinator: SelectImageCoordinator
    let faceFeatureDetector: FaceFeaturesDetector?
    let imageProcessor: ImageProcessor
    
    let apiClient: APIClient

    
    init(coordinator: SelectImageCoordinator,
         checkBoxViewModel: CheckViewModel,
         apiClient: APIClient,
         imageProcessor: ImageProcessor,
         faceFeatureDetector: FaceFeaturesDetector? = nil,
         animated: Bool = false) {
        self.coordinator = coordinator
        self.faceFeatureDetector = faceFeatureDetector
        self.imageProcessor = imageProcessor
        self.apiClient = apiClient
        self.animated = animated
        checkBoxOptions = checkBoxViewModel
        
        configure()
    }
    
    private func configureCheckBox() {
        checkBoxOptions.isChecked = true
        checkBoxOptions.title = "Analyze emotions".localized
        checkBoxOptions.foregroundColor = .gray
        // Combine could be used for subscbscription: checkBoxOptions.$isChecked.sink
    }
    
    private func configure() {
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
        
        
        let imageData = newImage.pngOrJPEGData()
        azureOperations.removeValue(forKey: option)?.cancel()
        guard let imageData = imageData else {
            return
        }
        
        //TODO: use as an example image https://www.pngkey.com/png/full/364-3645515_happy-woman-happy-face-woman-png.png
        
        //TODO: display progress bar...
        let ciImage = CIImage(data: imageData)
        let faceFeatures = ciImage.flatMap { self.faceFeatureDetector?.detectFaceExpressions(image: $0,
                                                                                             orientation: nil) } ?? [:]
        
        guard let firstFaceFeature = faceFeatures.first?.value else {
            displayAlert(message: "No face detected".localized)
            return
        }
        imageFeatures[option] = firstFaceFeature
        
        
        let newOp = apiClient.detectUserFrom(imageData: imageData) { [weak self] result in
            guard let self = self, self.azureOperations.removeValue(forKey: option).hasValue else { return }
            debugPrint("Received results for azure operation with option \(option)")
            do {
                let faceModels = try result.get()
                //TODO: process faceModels....
                if let firstModel = faceModels.first {
                    self.azureIds[option] = firstModel
                    debugPrint("!! Received azure first model is happy \(firstModel.faceAttributes.emotion?.happiness ?? 0.0)")
                    self.detectSimilarityOnNeed()
                } else {
                    self.azureIds.removeValue(forKey: option)
                }
            } catch {
                guard !error.isCancelled else { return }
                debugPrint("!! Azure processing error \(error.localizedDescription)")
                self.displayAlert(error: error)
            }
        }
        debugPrint("Scheduled azure operation for option \(option)")
        azureOperations[option] = newOp
    }
    
    private func displayAlert(message: String) {
        alertMessage = message
        displayAlert = true
    }
    
    private func displayAlert(error: Error) {
        displayAlert(message: error.localizedDescription)
    }
    
    private func detectSimilarityOnNeed() {
        let ids = azureIds.values.map({ $0.id })
        guard ids.count == 2, let faceId1 = ids.first, let faceId2 = ids.last else {
            return
        }
        
        identityOperation?.cancel()
        
        let newOp = apiClient.identify(faceId1: faceId1, faceId2: faceId2) { [weak self] result in
            guard let self = self else { return }
            self.identityOperation = nil
            do {
                let identityModel = try result.get()
                self.displayAlert(message: (identityModel.identical ? "Similar person on photoes" : "Seems that we have different persons").localized)
            } catch {
                self.displayAlert(error: error)
            }
        }
        identityOperation = newOp
    }
    
    func onDismiss(option: SelectionImageOption) {}
    
    func onTapGesture(option: SelectionImageOption) {
        showSheet = true
    }
}
