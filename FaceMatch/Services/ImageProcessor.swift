//
//  ImageProcessor.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 15.10.21.
//

import Foundation
import UIKit
import QuartzCore

struct ImageProcessor {
    private let context: CIContext
    
    private static func monochromeContext() -> CIContext {
        let colorspace = CGColorSpaceCreateDeviceGray()
        var dic: [CIContextOption: Any] = [CIContextOption.outputColorSpace: colorspace]
        dic[CIContextOption.allowLowPower] = NSNumber(booleanLiteral: true)
        let context = CIContext(options: dic)
        return context
    }
    
    init() {
        context = Self.monochromeContext()
    }
    
    func compress(image uiImage: UIImage,
                  initialScale: CGFloat = 1.0,
                  sizeInMbRatio: CGFloat = 0.3) -> UIImage {
        func imageOrDefault(from data: Data?) -> UIImage {
            data.flatMap { UIImage(data: $0) } ?? uiImage
        }
        
        //assert(!Thread.isMainThread)
        // 3 MB...
        var scale: CGFloat = initialScale
        var data: Data!
        let sizeInBytes = Int(sizeInMbRatio * 1024 * 1024)
        var skipOnce = true
        repeat {
            let compression: CGFloat
            let image: UIImage!
            if skipOnce {
                skipOnce = false
                compression = 0.6
                image = uiImage
            } else {
                scale = scale * 0.8
                image = uiImage.scaledImage(by: scale)
                compression = 0.8
            }

            let newData = image?.jpegData(compressionQuality: compression)  ?? .init()

            if newData.isEmpty, !data.isEmpty {
                return imageOrDefault(from: data)
            }
            
            data = newData
        } while data.count >= sizeInBytes // 512KB
        return imageOrDefault(from: data)
    }
    
    private func monochromeUIImage(ciImage: CIImage,
                                   relativeSize: CGSize = .zero) -> UIImage? {
        var extent = ciImage.extent
        if relativeSize != .zero {
            let sX = relativeSize.width
            let sY = relativeSize.height
            assert(sY <= 1 && sX <= 1)
            let oX = ciImage.extent.width * (1 - sX)/2
            let oY = ciImage.extent.height * (1 - sY)/2
            let origin = CGPoint(x: oX,
                                 y: oY)
            let size = CGSize(width: ciImage.extent.width * sX,
                              height: ciImage.extent.height * sY)

            extent = .init(origin: origin,
                           size: size)
        }
        guard let cgImage = context.createCGImage(ciImage, from: extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func convertToMonochrome(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        return monochromeUIImage(ciImage: ciImage,
                                 relativeSize: .zero)
    }
}
