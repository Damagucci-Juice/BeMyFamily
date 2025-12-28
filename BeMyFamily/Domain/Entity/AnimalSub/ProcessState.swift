//
//  ProcessState.swift
//  BeMyFamily
//
//  Created by Gucci on 4/23/24.
//

import Foundation

enum ProcessState: String, CaseIterable {
    case inProtect
    case notice
    case all

    var id: String {
        return self.rawValue
    }

    var param: String? {
        switch self {
        case .inProtect:
            return "protect"
        case .notice:
            return "notice"
        case .all:
            return nil
        }
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

enum InNoticeProcessState: String {
    case inProtect = "보호중"
    case endReturn = "종료(반환)"
    case endNaturalDeath = "종료(자연사)"
    case endMercyKill = "종료(안락사)"
    case endDonate = "종료(기증)"
    case endOther = "종료(기타)"
    case unknown = "알 수 없음"
}
