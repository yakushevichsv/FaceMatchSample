//
//  String+Ext.swift
//  FaceMatch
//
//  Created by Siarhei Yakushevich on 10.10.21.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: self)
    }
}
