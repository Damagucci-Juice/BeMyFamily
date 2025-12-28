//
//  Neutralization.swift
//  BeMyFamily
//
//  Created by Gucci on 4/23/24.
//

import Foundation

enum Neutralization: String, Codable, CaseIterable {
    case yes = "Y"
    // swiftlint: disable identifier_name
    case no = "N"
    // swiftlint: enable identifier_name
    case unknown = "U"

    var id: String {
        return self.rawValue
    }

    var text: String {
        switch self {
        case .yes:
            return "완료"
        case .no:
            return "안함"
        case .unknown:
            return "알 수 없음"
        }
    }
}
