//
//  Error+Ext.swift
//  LifeTechValidator
//
//  Created by SiarheiYakushevich on 18.12.2020.
//  Copyright © 2020 SY LLC. All rights reserved.
//

import Foundation

public extension Error {
    var isCancelled: Bool {
        return (self as NSError).isCancelled
    }

    var isNetworkAccessError: Bool {
        return (self as NSError).isNetworkAccessError
    }
}

public extension NSError {
    var isCancelled: Bool {
        return domain == NSURLErrorDomain &&
               code == NSURLErrorCancelled
    }

    var isNetworkAccessError: Bool {
        return domain == NSURLErrorDomain &&
               (code == NSURLErrorCannotFindHost ||
                code == NSURLErrorCannotConnectToHost ||
                code == NSURLErrorNotConnectedToInternet ||
                code == NSURLErrorNetworkConnectionLost)

    }
}
