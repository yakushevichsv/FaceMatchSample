//
//  FaceSmileDetector.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 15.10.21.
//

import Foundation
import CoreImage

// MARK: - FaceFeaturesInfo
struct FaceFeaturesInfo {
    let id: Int
    let smile: Bool
    let eyeClosed: Bool
}

// MARK: - FaceFeaturesDetector
struct FaceFeaturesDetector {
    let cid: CIDetector
    init?(context: CIContext? = nil,
          tracking: Bool = true,
          highAccuracy: Bool = true) {
         guard let cid = CIDetector(ofType: CIDetectorTypeFace,
                          context: context,
                          options: [CIDetectorAccuracy: highAccuracy ? CIDetectorAccuracyHigh
                                                                     : CIDetectorAccuracyLow,
                                    CIDetectorTracking: tracking,
                                    CIDetectorMaxFeatureCount: 10]) else {
                            return nil
        }
        self.cid = cid
    }

    func detectFaceExpressions(image: CIImage,
                               orientation: CGImagePropertyOrientation? = nil) -> [Int: FaceFeaturesInfo] {
        var dic: [String: Any] = [CIDetectorSmile: true,
                                  CIDetectorEyeBlink: true]
        if let orientation = orientation {
            dic[CIDetectorImageOrientation] = Int(orientation.rawValue)
        }
        let features = cid.features(in: image,
                                    options: dic)
        var result = [Int: FaceFeaturesInfo]()
        for feature in features where feature is CIFaceFeature {
            let face = feature as! CIFaceFeature
            var id = Int32.min
            if face.hasTrackingID {
                id = face.trackingID
            }
            debugPrint("!!! Track ID \(id) Smile \(face.hasSmile)")
            result[Int(id)] = FaceFeaturesInfo(id: Int(id),
                                               smile: face.hasSmile,
                                               eyeClosed: face.leftEyeClosed || face.rightEyeClosed)
        }
        return result
    }
}
