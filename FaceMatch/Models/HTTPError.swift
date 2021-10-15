//
//  HTTPError.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 15.10.21.
//

import Foundation

enum HTTPError: Error {
    case statusCode(value: Int?)
    case azure(error: AzureError)
    
    var localizedDescription: String {
        switch self {
        case let .azure(error):
            return error.localizedDescription
        case .statusCode(let value):
            if let value = value {
                return "Invalid Status Code:".localized + " \(value)"
            }
            return ""
        }
    }

    static func localizedDescriptionOrDefault(error: Error) -> String {
        let text = error.localizedDescription
        
        return text.isEmpty ? "Error".localized : text.localized
    }
}
