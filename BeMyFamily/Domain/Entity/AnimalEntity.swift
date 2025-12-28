//
//  AnimalEntity.swift
//  BeMyFamily
//
//  Created by Gucci on 12/21/25.
//
import Foundation

struct AnimalEntity: Identifiable, Hashable {
    var id: String { noticeNumber }
    private(set) var isFavorite: Bool
    let desertionNo: String
    let noticeNumber: String
    let noticeStartDate: String
    let noticeEndDate: String
    let processState: InNoticeProcessState
    let happenDate: String
    let happenPlace: String
    let updatedTime: String?
    let endReason: String?          // 사인: 수의사 판단으로한 안락사

    let kind: KindEntity
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

extension AnimalEntity {
    // 공고 등록 후 경과 시간을 문자열로 반환 (14일 기준 단위 변경)
    var relativeNoticeDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"

        guard let startDate = formatter.date(from: noticeStartDate) else {
            return ""
        }

        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: startDate, to: now)

        guard let day = components.day else { return "" }

        if day == 0 {
            return "오늘"
        } else if day <= 14 {
            // 1일 전 ~ 14일 전까지 표시
            return "\(day)일 전"
        } else {
            // 14일 이후부터는 주 단위로 계산
            let week = day / 7
            return "\(week)주 전"
        }
    }
}

extension AnimalEntity {
    // 공고 시작일 변환: 20251215 -> 2025년 12월 15일
    var noticeStartText: String {
        formatDate(noticeStartDate)
    }

    // 공고 종료일 변환: 20251215 -> 2025년 12월 15일
    var noticeEndText: String {
        formatDate(noticeEndDate)
    }

    // 내부 공통 포맷터 함수
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd" // 원래 데이터 형식

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy년 MM월 dd일" // 표시하고 싶은 형식

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }

        return dateString // 변환 실패 시 원본 반환
    }
}
