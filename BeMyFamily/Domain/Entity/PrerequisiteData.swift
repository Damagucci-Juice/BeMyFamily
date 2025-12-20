//
//  PrerequisiteData.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//
import Foundation

typealias Province = [SidoDTO: [SigunguDTO]]

struct PrerequisiteData {
    let kind: [Upkind: [KindDTO]]
    let sido: [SidoDTO]
    let province: Province
    let shelter: [SigunguDTO: [ShelterDTO]]
}
