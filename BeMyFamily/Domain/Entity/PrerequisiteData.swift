//
//  PrerequisiteData.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//
import Foundation

struct PrerequisiteData {
    let kind: [Upkind: [KindEntity]]
    let sido: [SidoEntity]
    let province: Province
    let shelter: [SigunguEntity: [ShelterEntity]]
}
