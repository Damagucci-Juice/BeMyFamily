//
//  Animal.swift
//  BeMyFamily
//
//  Created by Gucci on 4/17/24.
//

import Foundation

@Observable
final class Animal: Codable, Equatable, Identifiable {
    // 1. 기본 식별자 및 상태
    let id: String
    var isFavorite = false

    // 2. 이미지 및 공고 관련 (확장됨)
    let thumbnailURL: String
    let photoURL: String
    let noticeNo: String
    let noticeSdt: String
    let noticeEdt: String
    let processState: String

    // 3. 동물 상세 정보 (String 타입으로 통합)
    let happenDt: String
    let happenPlace: String
    let kindCD: String
    let kindNm: String
    let upKindCD: String
    let colorCD: String
    let age: String
    let weight: String
    let sexCD: SexCD
    let neuterYn: Neutralization
    let specialMark: String

    // 4. 관리 및 보호소 정보 (확장됨)
    let careNm: String
    let careTel: String
    let careAddr: String
    let orgNm: String
    let chargeNm: String?
    let officetel: String?
    let careRegNo: String
    let careOwnerNm: String

    // 5. 입양 관련 추가 정보 (Optional)
    let adptnTitle: String?
    let adptnSDate: String?
    let adptnEDate: String?

    enum CodingKeys: String, CodingKey {
        case id = "desertionNo"
        case thumbnailURL = "popfile1"
        case photoURL = "popfile2"
        case kindCD = "kindCd"
        case upKindCD = "upKindCd"
        case colorCD = "colorCd"
        case sexCD = "sexCd"
        case happenDt, happenPlace, kindNm, age, weight, noticeNo, noticeSdt, noticeEdt
        case processState, neuterYn, specialMark, careNm, careTel, careAddr
        case orgNm, chargeNm, officetel, careRegNo, careOwnerNm
        case adptnTitle, adptnSDate, adptnEDate
    }
}

extension Animal: Hashable {
    static func == (lhs: Animal, rhs: Animal) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
