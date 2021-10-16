//
//  APIClient.swift
//  LifeTechValidator
//
//  Created by SiarheiYakushevich on 05.12.2020.
//  Copyright © 2020 SY LLC. All rights reserved.
//

import UIKit
import Combine

typealias AzureDetectOperationResult = Result<[FaceModel], Error>
typealias AzureIdentifyOperationResult = Result<FaceIdentityModel, Error>
typealias CancellableOperation = AnyCancellable

final class APIClient {    
    typealias AzureDetectCompletionBlockType = (_ result: AzureDetectOperationResult) -> Void
    typealias AzureIdentityCompletionBlockType = (_ result: AzureIdentifyOperationResult) -> Void

    let session = URLSession(configuration: .default)
    let subscriptionKey = "1cf64ee7a9184ba88807108653183ac6"
    let baseURL = URL(string: "https://yakushevichsv.cognitiveservices.azure.com/face/v1.0")
    
    func detectUserFrom(imageData data: Data,
                        completion callback: @escaping AzureDetectCompletionBlockType) -> CancellableOperation {
        let relativePath = "detect"

        let queryItems: [String: Any] = ["returnFaceId": true,
            "returnFaceLandmarks": false,
            "recognitionModel": "recognition_01",
            "returnFaceAttributes": "emotion",
            "returnRecognitionModel": false,
            "detectionModel": "detection_01"
        ]
        var components = URLComponents(url: baseURL!.appendingPathComponent(relativePath),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.map({ (arg) -> URLQueryItem in

            let (key, value) = arg
            return .init(name: key, value: (value as? String) ?? (value as? Bool)?.description ?? "")
        })
        let url = components?.url
        var request = URLRequest(url: url!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 60)
        request.httpMethod = "POST"
        request.httpBody = data

        //binary data
        var lengthStr = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: ByteCountFormatter.CountStyle.file)
        lengthStr = "\(data.count)"

        request.addValue(lengthStr, forHTTPHeaderField: "Content-Length")
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        request.addValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        debugPrint(#function + " Detecting user")
        let result = session.dataTaskPublisher(for: request).tryCompactMap { (output) -> Data? in
            let responsePtr = output.response as? HTTPURLResponse
            let code = responsePtr?.statusCode
            guard code == 200 else {
                let decoder = JSONDecoder()
                if let wrapper = try? decoder.decode(AzureWrapper.self, from: output.data), !wrapper.error.isEmpty {
                    var error = wrapper.error
                    if error.statusCode == nil {
                        error.statusCode = code
                    }
                    throw HTTPError.azure(error: error)
                } else {
                    throw HTTPError.statusCode(value: code)
                }
            }
            return output.data
        }.tryMap{ data in
            try JSONDecoder().decode([FaceModel].self, from: data)
        }
        .receive(on: DispatchQueue.main, options: nil)
        .sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                callback(.failure(error))
            }
        }, receiveValue: { (faceModel) in
            callback(.success(faceModel))
        })
        return result
    }

    func identify(faceId1: String,
                  faceId2: String,
                  completion callback: @escaping  AzureIdentityCompletionBlockType) -> CancellableOperation {

        let relativePath = "verify"

        let components = URLComponents(url: baseURL!.appendingPathComponent(relativePath),
                                       resolvingAgainstBaseURL: false)
        let url = components?.url
        var request = URLRequest(url: url!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 60)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let bodyDic = ["faceId1": faceId1,
                       "faceId2": faceId2]
        let jsonData = try! JSONSerialization.data(withJSONObject: bodyDic, options: .prettyPrinted)

        request.httpBody = jsonData

        request.addValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        debugPrint(#function + " Identifying that we have same users")
        let result = session.dataTaskPublisher(for: request).tryCompactMap { (output) -> Data? in
            let responsePtr = output.response as? HTTPURLResponse
            let code = responsePtr?.statusCode
            guard code == 200 else {
                if let wrapper = try? JSONDecoder().decode(AzureWrapper.self, from: output.data), !wrapper.error.isEmpty {
                    var error = wrapper.error
                    if error.statusCode == nil {
                        error.statusCode = code
                    }
                    throw HTTPError.azure(error: error)
                } else {
                    throw HTTPError.statusCode(value: code)
                }
            }
            return output.data
        }.tryMap{ data in
            try JSONDecoder().decode(FaceIdentityModel.self, from: data)
        }.receive(on: DispatchQueue.main, options: nil)
        .sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                callback(.failure(error))
            }
        }) { (model) in
            callback(.success(model))
        }
        return result
    }
}
