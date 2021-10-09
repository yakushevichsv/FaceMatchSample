//
//  FaceMatchApp.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

@main
struct FaceMatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView { //TODO: Coordinator...
                SelectImageVIew(viewModel: .init())
            }
        }
    }
}
