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
        
        //same person after 6 years -
        /* https://static.boredpanda.com/blog/wp-content/uploads/2020/08/children-photos-before-and-after-6-years-etojiviefoto-nikita-khnyunin-5f2a596c3600b__880.jpg */
        
        //TODO: display progress bar...
        let ciImage = CIImage(data: imageData)
        let faceFeatures = ciImage.flatMap { faceFeatureDetector?.detectFaceExpressions(image: $0) }
        
        let values = faceFeatures?.values.map { $0 }
        
        if let values = values, !values.isEmpty {
            imageFeatures[option] = values.first!
            if values.count == 2, let last = values.last {
                let newOption: SelectionImageOption
                switch option {
                case .first:
                    newOption = .second
                case .second:
                    newOption = .first
                }
                imageFeatures[newOption] = last
            }
        } else {
            imageFeatures.removeValue(forKey: option)
            if faceFeatureDetector.hasValue {
                displayAlert(message: "No face detected".localized)
            }
        }
        
        let newOp = apiClient.detectUserFrom(imageData: imageData)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.azureOperations.removeValue(forKey: option)
            guard let self = self, case .failure(let error) = completion else {
                return
            }
            guard !error.isCancelled else { return }
            debugPrint("!! Azure processing error \(error.localizedDescription)")
            self.displayAlert(error: error)
        } receiveValue: { [weak self] faceModels in
            self?.process(option: option,
                          faceModels: faceModels)
        }

        debugPrint("Scheduled azure operation for option \(option)")
        azureOperations[option] = newOp
    }
    
    private func process(option: SelectionImageOption,
                         faceModels: [FaceModel]) {
        guard azureOperations.removeValue(forKey: option).hasValue else { return }
        debugPrint("Received results for azure operation with option \(option)")
        if let firstModel = faceModels.first {
            azureIds[option] = firstModel
            if faceModels.count == 2, let last = faceModels.last {
                let newOption: SelectionImageOption
                switch option {
                case .first:
                    newOption = .second
                case .second:
                    newOption = .first
                }
                azureIds[newOption] = last
            }
            debugPrint("!! Received azure first model is happy \(firstModel.faceAttributes.emotion?.happiness ?? 0.0)")
            detectSimilarityOnNeed()
        } else {
            azureIds.removeValue(forKey: option)
            displayAlert(message: "No face detected".localized)
        }
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
        let keyPath = \SelectImageViewModel.identityOperation
        self[keyPath: keyPath]?.cancel()
        
        self[keyPath: keyPath] = apiClient.identify(faceId1: faceId1, faceId2: faceId2)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?[keyPath: keyPath] = nil
            guard let self = self, case .failure(let error) = completion else {
                return
            }
            guard !error.isCancelled else { return }
            debugPrint("!! detectSimilarityOnNeed \(error.localizedDescription)")
            self.displayAlert(error: error)
        } receiveValue: { [weak self] identityModel in
            self?.displayAlert(message: (identityModel.identical ? "Similar person on photoes" : "Seems that we have different persons").localized)
        }
    }
    
    func onDismiss(option: SelectionImageOption) {}
    
    func onTapGesture(option: SelectionImageOption) {
        showSheet = true
    }
}
