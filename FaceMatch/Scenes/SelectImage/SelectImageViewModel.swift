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
    
    let title: String
    
    private (set)var options = [SelectionImageOption]()
    
    let checkBoxOptions: CheckViewModel
    lazy var coordinator: SelectImageCoordinator = {
        .init(viewModel: self)
    }()
    
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
    }
    
    func onDismiss(optin: SelectionImageOption) {}
    
    func onTapGesture(option: SelectionImageOption) {
        showSheet = true
    }
}
