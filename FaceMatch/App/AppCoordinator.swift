//
//  AppCoordinator.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

final class AppCoordinator {
    func rootView() -> some View {
        NavigationView {
            SelectImageVIew(viewModel: rootModel())
        }
    }
    
    func rootModel() -> SelectImageViewModel {
        let coordinator = SelectImageCoordinator()
        let viewModel = SelectImageViewModel(coordinator: coordinator,
                                             checkBoxViewModel: .init(),
                                             apiClient: .init(),
                                             imageProcessor: .init())
        coordinator.viewModel = viewModel
        return viewModel
    }
}
