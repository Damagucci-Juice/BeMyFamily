//
//  ProcessState.swift
//  BeMyFamily
//
//  Created by Gucci on 4/23/24.
//

import Foundation

enum ProcessState: String, CaseIterable {
    case inProtect = "protect"
    case notice = "notice"
    case all = ""

    var id: String {
        return self.rawValue
    }

    var text: String {
        switch self {
        case .inProtect:
            return "보호중"
        case .notice:
            return "공고중"
        case .all:
            return "전체보기"
        }
    }
}
