//
//  FaceModel.swift
//  LifeTechValidator
//
//  Created by SiarheiYakushevich on 06.12.2020.
//  Copyright © 2020 SY LLC. All rights reserved.
//

import Foundation

// MARK: - FaceRect
struct FaceRect {
    let top, left, width, height: Float
}

// MARK: - Emotion
struct Emotion {
    let anger, happiness: Float
}

// MARK: - FaceAttributes
struct FaceAttributes {
    let emotion: Emotion?
}

// MARK: - FaceModel
struct FaceModel {
    let id: String
    let rect: FaceRect
    let faceAttributes: FaceAttributes
}

// MARK: - AzureWrapper
struct AzureWrapper {
    let error: AzureError
}

// MARK: - FaceIdentityModel
struct FaceIdentityModel {
    let identical: Bool
    let confidence: Float
}


// MARK: - FaceIdentityModel.Decodable
extension FaceIdentityModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case identical = "isIdentical"
        case confidence
    }

    public init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        let identical = try container.decode(Bool.self, forKey: .identical)
        let confidence = try container.decode(Float.self, forKey: .confidence)
        self.init(identical: identical,
                  confidence: confidence)
    }
}

// MARK: - AzureWrapper.Decodable
extension AzureWrapper: Decodable {
    enum CodingKeys: String, CodingKey {
        case error
    }

    public init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        let error = try container.decode(AzureError.self, forKey: .error)
        self.init(error: error)
    }
}

// MARK: - FaceRect.Decodable
extension FaceRect: Decodable {
    enum CodingKeys: String, CodingKey {
        case top
        case left
        case width
        case height
    }

    public init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        let top = try? container.decode(Float.self, forKey: .top)
        let left = try? container.decode(Float.self, forKey: .left)
        let width = try? container.decode(Float.self, forKey: .width)
        let height = try? container.decode(Float.self, forKey: .height)

        self.init(top: top ?? 0,
                  left: left ?? 0,
                  width: width ?? 0,
                  height: height ?? 0)
    }
}

// MARK: - Emotion.Decodable
extension Emotion: Decodable {
    enum CodingKeys: String, CodingKey {
        case anger
        case happiness
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let anger = try? container.decode(Float.self, forKey: .anger)
        let happiness = try? container.decode(Float.self, forKey: .happiness)
        self.init(anger: anger ?? 0,
                  happiness: happiness ?? 0 )
    }
}

// MARK: - FaceAttributes.Decodable
extension FaceAttributes: Decodable {
    enum CodingKeys: String, CodingKey {
        case emotion
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let emotion = try container.decode(Emotion.self, forKey: .emotion)
        self.init(emotion: emotion)
    }
}

// MARK: - FaceModel.Decodable
extension FaceModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "faceId"
        case rect = "faceRectangle"
        case faceAttributes = "faceAttributes"
    }

    public init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let rect = try container.decode(FaceRect.self, forKey: .rect)
        let faceAttributes = try container.decode(FaceAttributes.self, forKey: .faceAttributes)
        self.init(id: id,
                  rect: rect,
                  faceAttributes: faceAttributes)
    }
}
