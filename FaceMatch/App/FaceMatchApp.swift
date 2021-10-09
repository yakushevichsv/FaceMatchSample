//
//  FaceMatchApp.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI

@main
struct FaceMatchApp: App {
    let coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            coordinator.rootView()
        }
    }
}
