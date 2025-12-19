//
//  Sido.swift
//  BeMyFamily
//
//  Created by Gucci on 4/17/24.
//

import Foundation

struct Sido: Codable, Identifiable, Hashable {
    let id: String
    let name: String

    static let example = Self(id: "6110000", name: "서울특별시")

    enum CodingKeys: String, CodingKey {
        case id = "orgCd"
        case name = "orgdownNm"
    }
}
