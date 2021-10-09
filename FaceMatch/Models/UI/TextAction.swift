//
//  TextActionInfo.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 9.10.21.
//

import Foundation

typealias EmptyVoidBlockAlias = (() -> Void)

// MARK: - TextAction
struct TextAction {
    let text: String
    let action: EmptyVoidBlockAlias
    init(text: String,
         action: @escaping EmptyVoidBlockAlias = {}) {
        self.text = text
        self.action = action
    }
}

