//
//  Shelter.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//

import Foundation

struct Shelter: Codable, Hashable, Identifiable {
    let id: String
    let name: String

    static let example = Self(id: "311322200900001", name: "한국동물구조관리협회")

    enum CodingKeys: String, CodingKey {
        case id = "careRegNo"
        case name = "careNm"
    }
}
