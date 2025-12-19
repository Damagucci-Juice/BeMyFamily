//
//  Sigungu.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//

import Foundation

struct Sigungu: Codable, Hashable, Identifiable {
    let id: String
    let name: String?
    let sidoId: String

    static let example = Self(id: "3220000", name: "강남구", sidoId: "6110000")

    enum CodingKeys: String, CodingKey {
        case id = "orgCd"
        case name = "orgdownNm"
        case sidoId = "uprCd"
    }
}
