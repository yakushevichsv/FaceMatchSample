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

enum SelectionImageOption: CaseIterable {
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

extension SelectionImageOption: Identifiable {
    var id: Int {
        SelectionImageOption.allCases.firstIndex(of: self)!
    }
}

import SwiftUI
import Combine

// MARK: - SelectImageViewModel
final class SelectImageViewModel: ObservableObject {
    
    @Published var animated: Bool
    
    let title: String
    let stepTitle: String
    let index: Int
    
    private (set)var options = [SelectionImageOption]()
    private (set)var disposeBag = Set<AnyCancellable>()
    
    let checkBoxOptions: CheckViewModel?
    lazy var coordinator: SelectImageCoordinator = {
        .init(viewModel: self)
    }()
    
    init(index: Int = 0,
         animated: Bool = false) {
        self.animated = animated
        title = "Select Image Source".localized
        stepTitle = String(format: "Step %d".localized, index)
        self.index = index
        let hasCheckBox = index == 0
        checkBoxOptions = hasCheckBox ? .init() : nil
        configure()
    }
    
    private func configure() {
        
        options = SelectionImageOption.allCases
        
        if let checkBoxOptions = checkBoxOptions {
            checkBoxOptions.isChecked = true
            checkBoxOptions.title = "Same choice for the next step".localized
            checkBoxOptions.foregroundColor = .gray
            checkBoxOptions.$isChecked.sink { [unowned self] isChecked in
                //TODO: here...
                debugPrint("!!! isChecked \(isChecked)")
            }.store(in: &disposeBag)
        }
    }
    
    func onAppear() {
        if !animated {
            animated.toggle()
        }
    }
}
