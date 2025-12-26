//
//  Mapper.swift
//  BeMyFamily
//
//  Created by Gucci on 12/21/25.
//

struct Mapper {
    static func animalDto2Entity(_ dto: AnimalDTO) -> AnimalEntity {
        return AnimalEntity(
            isFavorite: false,
            desertionNo: dto.desertionNo,
            noticeNumber: dto.noticeNo,
            noticeStartDate: dto.noticeSdt,
            noticeEndDate: dto.noticeEdt,
            processState: dto.processState,
            happenDate: dto.happenDt,
            happenPlace: dto.happenPlace,
            updatedTime: dto.updTm,
            endReason: dto.endReason,
            kindCode: dto.kindCd,
            kindName: dto.kindNm,
            kindFullName: dto.kindFullNm,
            upKindCode: dto.upKindCd,
            upKindName: dto.upKindNm,
            color: dto.colorCd,
            age: dto.age,
            weight: dto.weight,
            sexCd: SexCD(rawValue: dto.sexCd) ?? .unknown,
            neuterYn: Neutralization(rawValue: dto.neuterYn) ?? .unknown,
            specialMark: dto.specialMark,
            rfid: dto.rfidCd,
            image1: dto.popfile1,
            image2: dto.popfile2,
            careName: dto.careNm,
            careTel: dto.careTel,
            careAddress: dto.careAddr,
            oranizationName: dto.orgNm,
            careRegisterNumber: dto.careRegNo,
            careOwnerName: dto.careOwnerNm,
            disease: dto.healthChk,
            vaccinationStatus: dto.vaccinationChk,
            socialization: dto.sfeSoci,
            healthStatus: dto.sfeHealth,
            etcBigo: dto.etcBigo,
            adptnTitle: dto.adptnTitle,
            adptnSDate: dto.adptnSDate,
            adptnEDate: dto.adptnEDate,
            adptnConditionLimitTxt: dto.adptnConditionLimitTxt,
            adptnTxt: dto.adptnTxt,
            adptnImg: dto.adptnImg
        )
    }

    static func animalEntity2Dto(_ entity: AnimalEntity) -> AnimalDTO {
        return AnimalDTO(
            desertionNo: entity.desertionNo,
            noticeNo: entity.noticeNumber,
            noticeSdt: entity.noticeStartDate,
            noticeEdt: entity.noticeEndDate,
            processState: entity.processState,
            happenDt: entity.happenDate,
            happenPlace: entity.happenPlace,
            updTm: entity.updatedTime,
            endReason: entity.endReason,
            kindCd: entity.kindCode,
            kindNm: entity.kindName,
            kindFullNm: entity.kindFullName,
            upKindCd: entity.upKindCode,
            upKindNm: entity.upKindName,
            colorCd: entity.color,
            age: entity.age,
            weight: entity.weight,
            sexCd: entity.sexCd.rawValue, // Enum의 rawValue 사용
            neuterYn: entity.neuterYn.rawValue, // Enum의 rawValue 사용
            specialMark: entity.specialMark,
            rfidCd: entity.rfid,
            popfile1: entity.image1,
            popfile2: entity.image2,
            popfile3: nil, // AnimalEntity에 없음
            popfile4: nil, // AnimalEntity에 없음
            popfile5: nil, // AnimalEntity에 없음
            popfile6: nil, // AnimalEntity에 없음
            popfile7: nil, // AnimalEntity에 없음
            popfile8: nil, // AnimalEntity에 없음
            careNm: entity.careName,
            careTel: entity.careTel,
            careAddr: entity.careAddress,
            orgNm: entity.oranizationName,
            careRegNo: entity.careRegisterNumber,
            careOwnerNm: entity.careOwnerName,
            healthChk: entity.disease,
            vaccinationChk: entity.vaccinationStatus,
            sfeSoci: entity.socialization,
            sfeHealth: entity.healthStatus,
            etcBigo: entity.etcBigo,
            adptnTitle: entity.adptnTitle,
            adptnSDate: entity.adptnSDate,
            adptnEDate: entity.adptnEDate,
            adptnConditionLimitTxt: entity.adptnConditionLimitTxt,
            adptnTxt: entity.adptnTxt,
            adptnImg: entity.adptnImg,
            sprtTitle: nil, // AnimalEntity에 없음
            sprtSDate: nil, // AnimalEntity에 없음
            sprtEDate: nil, // AnimalEntity에 없음
            sprtConditionLimitTxt: nil, // AnimalEntity에 없음
            sprtTxt: nil, // AnimalEntity에 없음
            sprtImg: nil, // AnimalEntity에 없음
            srvcTitle: nil, // AnimalEntity에 없음
            srvcSDate: nil, // AnimalEntity에 없음
            srvcEDate: nil, // AnimalEntity에 없음
            srvcConditionLimitTxt: nil, // AnimalEntity에 없음
            srvcTxt: nil, // AnimalEntity에 없음
            srvcImg: nil, // AnimalEntity에 없음
            evntTitle: nil, // AnimalEntity에 없음
            evntSDate: nil, // AnimalEntity에 없음
            evntEDate: nil, // AnimalEntity에 없음
            evntConditionLimitTxt: nil, // AnimalEntity에 없음
            evntTxt: nil, // AnimalEntity에 없음
            evntImg: nil // AnimalEntity에 없음
        )
    }

    static func shelterDto2Entity(_ dto: ShelterDTO) -> ShelterEntity {
        return ShelterEntity(id: dto.id, name: dto.name)
    }

    static func shelterEntity2Dto(_ entity: ShelterEntity) -> ShelterDTO {
        ShelterDTO(id: entity.id, name: entity.name)
    }

    static func sidoDto2Entity(_ dto: SidoDTO) -> SidoEntity {
        return SidoEntity(id: dto.id, name: dto.name)
    }

    static func sidoEntity2Dto(_ entity: SidoEntity) -> SidoDTO {
        return SidoDTO(id: entity.id, name: entity.name)
    }

    static func sigunguDto2Entity(_ dto: SigunguDTO) -> SigunguEntity {
        return SigunguEntity(id: dto.id, name: dto.name, sidoCode: dto.sidoId)
    }

    static func sigunguEntity2Dto(_ entity: SigunguEntity) -> SigunguDTO {
        return SigunguDTO(id: entity.id, name: entity.name, sidoId: entity.sidoCode)
    }

    static func kindDto2Entity(_ dto: KindDTO) -> KindEntity {
        return KindEntity(
            id: String(Int(dto.id) ?? 0),
            name: dto.name
        )
    }

    static func kindEntity2Dto(_ entity: KindEntity) -> KindDTO {
        let intId = Int(entity.id) ?? 0
        let paddedId = String(format: "%06d", intId)

        return KindDTO(
            id: paddedId,
            name: entity.name
        )
    }

}
