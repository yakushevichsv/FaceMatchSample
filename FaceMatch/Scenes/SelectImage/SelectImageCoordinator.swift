//
//  SelectImageCoordinator.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import Foundation

final class SelectImageCoordinator {
    unowned var viewModel: SelectImageViewModel!
}

import SwiftUI
extension SelectImageCoordinator {
    func view(option: SelectionImageOption) -> some View {
        ImagePicker(selectedImage: .init(get: {
            self.viewModel.images[option]
        }, set: { newImage in
            self.viewModel.didSelect(image: newImage,
                                     for: option)
        }))
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
}
