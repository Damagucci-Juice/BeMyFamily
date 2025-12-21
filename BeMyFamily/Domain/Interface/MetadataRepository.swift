//
//  MetadataRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//

import Foundation

typealias Province = [SidoEntity: [SigunguEntity]]

protocol MetadataRepository {
    func fetchKinds() async throws -> [Upkind: [KindEntity]]
    func fetchSidos() async throws -> [SidoEntity]
    func fetchProvinces(_ sidos: [SidoEntity]) async throws -> Province
    func fetchShelters(_ province: Province) async throws -> [SigunguEntity: [ShelterEntity]]
}
