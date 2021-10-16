//
//  UImage+Ext.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 15.10.21.
//

import UIKit

extension UIImage {
    
    class func resize(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    class func scale(image: UIImage, by scale: CGFloat) -> UIImage? {
        let size = image.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return resize(image: image, targetSize: scaledSize)
    }

    func scaledImage(by scale: CGFloat) -> UIImage? {
        return type(of: self).scale(image: self, by: scale)
    }
    
    func pngOrJPEGData() -> Data? {
        pngData() ?? jpegData(compressionQuality: 1.0)
    }
}
