//
//  SelectImageViewModel.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: self)
    }
}

enum SelectionImageCase: Int {
    case camera
    case photos
    
    var title: String {
        switch self {
        case .camera:
            return "Camera"
        case .photos:
            return "Photos"
        }
    }
    
    var localizedTitle: String { title.localized }
}

import SwiftUI

// MARK: - SelectImageViewModel
final class SelectImageViewModel {
    
    let title: String
    let stepTitle: String
    let index: Int
    
    private (set)var options = [TextAction]()
    
    let checkBoxOptions: CheckViewModel?
    
    init(index: Int = 0) {
        title = "Select Image Source".localized
        stepTitle = String(format: "Step %d".localized, index)
        self.index = index
        let hasCheckBox = index == 0
        checkBoxOptions = hasCheckBox ? .init() : nil
        configure()
    }
    
    private func configure() {
        let cases = [SelectionImageCase.camera, .photos]
        
        options = cases.map { option in
            TextAction(text: option.localizedTitle) { [unowned self] in
                self.onButtonPressed(case: option)
            }
        }
        
        if let checkBoxOptions = checkBoxOptions {
            checkBoxOptions.isChecked = true
            checkBoxOptions.title = "Same choice for the next step".localized
            checkBoxOptions.foregroundColor = .gray
        }
    }
    
    private func onButtonPressed(case: SelectionImageCase) {
        
    }
}
