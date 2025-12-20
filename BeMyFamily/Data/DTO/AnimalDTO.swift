//
//  Animal.swift
//  BeMyFamily
//
//  Created by Gucci on 4/17/24.
//

import Foundation
import Foundation

struct AnimalDTO: Codable, Equatable, Identifiable {
    var id: String { noticeNo }
    let desertionNo: String                 // 구조번호: 새끼 여러마리 구조는 구조번호가 동일 할 수 있음

    // 2. 기본 공고 정보
    let noticeNo: String
    let noticeSdt: String
    let noticeEdt: String
    let processState: String
    let happenDt: String
    let happenPlace: String
    let updTm: String?
    let endReason: String?

    // 3. 동물 상세 정보
    let kindCd: String
    let kindNm: String
    let kindFullNm: String?
    let upKindCd: String
    let upKindNm: String?
    let colorCd: String
    let age: String
    let weight: String
    let sexCd: String              // 커스텀 Enum (JSON: "sexCd")
    let neuterYn: String  // 커스텀 Enum (JSON: "neuterYn")
    let specialMark: String
    let rfidCd: String?

    // 4. 이미지 필드 (popfile 1~8)
    let popfile1: String?
    let popfile2: String?
    let popfile3: String?
    let popfile4: String?
    let popfile5: String?
    let popfile6: String?
    let popfile7: String?
    let popfile8: String?

    // 5. 보호소 및 담당자 정보
    let careNm: String
    let careTel: String
    let careAddr: String
    let orgNm: String
    let careRegNo: String
    let careOwnerNm: String

    // 6. 건강 및 기타 정보
    let healthChk: String?
    let vaccinationChk: String?
    let sfeSoci: String?
    let sfeHealth: String?
    let etcBigo: String?

    // 7. 입양(adptn) / 지원(sprt) / 서비스(srvc) / 이벤트(evnt) 관련 확장 필드
    let adptnTitle: String?
    let adptnSDate: String?
    let adptnEDate: String?
    let adptnConditionLimitTxt: String?
    let adptnTxt: String?
    let adptnImg: String?

    let sprtTitle: String?
    let sprtSDate: String?
    let sprtEDate: String?
    let sprtConditionLimitTxt: String?
    let sprtTxt: String?
    let sprtImg: String?

    let srvcTitle: String?
    let srvcSDate: String?
    let srvcEDate: String?
    let srvcConditionLimitTxt: String?
    let srvcTxt: String?
    let srvcImg: String?

    let evntTitle: String?
    let evntSDate: String?
    let evntEDate: String?
    let evntConditionLimitTxt: String?
    let evntTxt: String?
    let evntImg: String?

    // JSON 키와 프로퍼티명이 일치하므로 CodingKeys는 불필요한 별칭(id) 설정 외에는 생략 가능합니다.
    enum CodingKeys: String, CodingKey {
        case desertionNo, noticeNo, srvcTxt, popfile4, sprtEDate, rfidCd, happenDt
        case happenPlace, kindCd, colorCd, age, weight, evntImg, updTm, endReason
        case careRegNo, noticeSdt, noticeEdt, popfile1, processState, sexCd, neuterYn
        case specialMark, careNm, careTel, careAddr, orgNm, sfeSoci, sfeHealth, etcBigo
        case kindFullNm, upKindCd, upKindNm, kindNm, popfile2, popfile3, popfile5
        case popfile6, popfile7, popfile8, careOwnerNm, vaccinationChk, healthChk
        case adptnTitle, adptnSDate, adptnEDate, adptnConditionLimitTxt, adptnTxt
        case adptnImg, sprtTitle, sprtSDate, sprtConditionLimitTxt, sprtTxt, sprtImg
        case srvcTitle, srvcSDate, srvcEDate, srvcConditionLimitTxt, srvcImg
        case evntTitle, evntSDate, evntEDate, evntConditionLimitTxt, evntTxt
    }
}

extension AnimalDTO: Hashable {
    static func == (lhs: AnimalDTO, rhs: AnimalDTO) -> Bool {
        lhs.desertionNo == rhs.desertionNo
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(desertionNo)
    }
}
