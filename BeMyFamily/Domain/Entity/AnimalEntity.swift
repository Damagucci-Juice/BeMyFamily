//
//  AnimalEntity.swift
//  BeMyFamily
//
//  Created by Gucci on 12/21/25.
//

struct AnimalEntity: Identifiable, Hashable {
    var id: String { noticeNumber }
    private(set) var isFavorite: Bool
    let desertionNo: String
    let noticeNumber: String
    let noticeStartDate: String
    let noticeEndDate: String
    let processState: String
    let happenDate: String
    let happenPlace: String
    let updatedTime: String?
    let endReason: String?          // 사인: 수의사 판단으로한 안락사

    let kindCode: String            // 610000
    let kindName: String            // 비숑프리제
    let kindFullName: String        // [개] 비숑프리제
    let upKindCode: String          // 417000
    let upKindName: String          // 개
    let color: String
    let age: String
    let weight: String
    let sexCd: SexCD                // 커스텀 Enum (JSON: "sexCd")
    let neuterYn: Neutralization    // 커스텀 Enum (JSON: "neuterYn")
    let specialMark: String         // 특징: 순함
    let rfid: String?               // 동물 등록번호: RFID(1000건중 49건있음)

    let image1: String
    let image2: String

    let careName: String
    let careTel: String
    let careAddress: String
    let oranizationName: String
    let careRegisterNumber: String
    let careOwnerName: String

    let disease: String?            // dto: HealthChk, ex) 홍역, 심장사상충
    let vaccinationStatus: String?  // 코로나, 독감
    let socialization: String?      // sfeSocial
    let healthStatus: String?       // sfeHealth
    let etcBigo: String?            // 그외 건강 특이

    // 입양(adptn) 필드
    let adptnTitle: String?
    let adptnSDate: String?
    let adptnEDate: String?
    let adptnConditionLimitTxt: String?
    let adptnTxt: String?
    let adptnImg: String?

    mutating func updateFavoriteStatus(_ currentStatus: Bool = false) {
        self.isFavorite = currentStatus
    }
}
