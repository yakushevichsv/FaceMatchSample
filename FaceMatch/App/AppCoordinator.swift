//
//  AppCoordinator.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

final class AppCoordinator {
    
    func rootView() -> some View {
        NavigationView { //TODO: Coordinator...
            SelectImageVIew(viewModel: .init())
        }
    }
}
