//
//  SelectImageContracts.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 10.10.21.
//

import Foundation

// MARK: - SelectionImageOption
enum SelectionImageOption: CaseIterable {
    case first
    case second
    
    var title: String {
        switch self {
        case .first:
            return "First"
        case .second:
            return "Second"
        }
    }
    
    var localizedTitle: String { title.localized }
}

// MARK: - SelectionImageOption.Identifiable
extension SelectionImageOption: Identifiable {
    var id: Int {
        SelectionImageOption.allCases.firstIndex(of: self)!
    }
}
