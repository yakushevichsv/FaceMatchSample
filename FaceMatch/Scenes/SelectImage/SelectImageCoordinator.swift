//
//  SelectImageCoordinator.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import Foundation

struct SelectImageCoordinator {
    private unowned var viewModel: SelectImageViewModel!
    init(viewModel: SelectImageViewModel) {
        self.viewModel = viewModel
    }
}

import SwiftUI
extension SelectImageCoordinator {
    func view(option: SelectionImageOption) -> some View {
        switch option {
        case .camera:
            return CameraView()
        case .photos:
            return PhotoLibraryView()
        }
    }
}
