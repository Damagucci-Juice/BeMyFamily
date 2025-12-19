//
//  SexCd.swift
//  BeMyFamily
//
//  Created by Gucci on 4/25/24.
//

import Foundation

enum SexCD: String, Codable, CaseIterable {
    case femail = "F"
    case male = "M"
    case unknown = "Q"

    var text: String {
        switch self {
        case .femail:
            return "암컷"
        case .male:
            return "수컷"
        case .unknown:
            return "미상"
        }
    }
}
