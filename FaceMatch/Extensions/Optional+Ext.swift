//
//  Optional+Ext.swift
//  FitGrid
//
//  Created by Siarhei Yakushevich on 3.09.21.
//  Copyright © 2021 FitGrid. All rights reserved.
//

import Foundation

extension Optional {
    var hasValue: Bool {
        if case .some = self {
            return true
        }
        return false
    }
    
    func valueOrDefault( _ def: Wrapped) -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            return def
        }
    }
}

extension Optional where Wrapped: StringProtocol {
    var valueOrEmpty: Wrapped {
        valueOrDefault("")
    }
}

extension Optional where Wrapped == Bool {
    var valueOrFalse: Wrapped {
        valueOrDefault(false)
    }
}

extension Optional where Wrapped: SignedInteger {
    var valueOrZero: Wrapped {
        valueOrDefault(0)
    }
}
