//
//  AzureError.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 15.10.21.
//

import Foundation

// MARK: - AzureError
struct AzureError: Error {
    let codeRaw: String?
    let message: String?
    var statusCode: Int?

    // All empty..
    var isEmpty: Bool {
        [codeRaw, message].first { $0?.isEmpty == false } == nil && statusCode == nil
    }

    var localizedDescription: String {
        message?.localized ?? ""
    }
}

// MARK: - AzureError.Decodable
extension AzureError: Decodable {
    enum CodingKeys: String, CodingKey {
        case codeRaw = "code"
        case message
        case statusCode
    }

    public init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        let codeRaw = try? container.decode(String.self, forKey: .codeRaw)
        let message = try? container.decode(String.self, forKey: .message)
        let statusCode = try? container.decode(Int.self, forKey: .statusCode)

        self.init(codeRaw: codeRaw,
                  message: message,
                  statusCode: statusCode)
    }
}

