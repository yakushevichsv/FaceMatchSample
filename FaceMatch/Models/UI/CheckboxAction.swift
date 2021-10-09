//
//  CheckboxAction.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import Foundation


struct CheckboxAction {
    let textAction: TextAction
    let isChecked: Bool
    
    init(isChecked: Bool,
         textAction: TextAction) {
        self.isChecked = isChecked
        self.textAction = textAction
    }
}
