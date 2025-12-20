//
//  PrerequisiteData.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//
import Foundation

typealias Province = [Sido: [Sigungu]]

struct PrerequisiteData {
    let kind: [Upkind: [Kind]]
    let sido: [Sido]
    let province: Province
    let shelter: [Sigungu: [Shelter]]
}
