//
//  Upkind.swift
//  BeMyFamily
//
//  Created by Gucci on 4/23/24.
//

import Foundation

enum Upkind: String, CaseIterable {
    case dog = "417000"
    case cat = "422400"
    case other = "429900"

    var id: String {
        return self.rawValue
    }
    var text: String {
        switch self {
        case .dog:
            return "강아지"
        case .cat:
            return "고양이"
        default:
            return "기타"
        }
    }
}
