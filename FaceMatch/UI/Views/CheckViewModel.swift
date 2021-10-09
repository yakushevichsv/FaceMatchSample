//
//  CheckViewModel.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import SwiftUI
//VM uses SwifUI
final class CheckViewModel: ObservableObject {
    @Published var isChecked: Bool = true
    
    var title: String?
    
    var textForegroundColor: Color?
    var foregroundColor: Color? {
        didSet {
            if let value = foregroundColor, textForegroundColor == nil {
                textForegroundColor = value
            }
        }
    }
    
    var systemImageName: String {
        isChecked ? "checkmark.square": "square"
    }
    
    func onPressed() {
        isChecked.toggle()
    }
}
