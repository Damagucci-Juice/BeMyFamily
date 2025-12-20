//
//  MetadataRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//

import Foundation

protocol MetadataRepository {
    func getKinds() async throws -> [Upkind: [KindDTO]]
    func getSidos() async throws -> [SidoDTO]
    func getProvinces(_ sidos: [SidoDTO]) async throws -> Province
    func getShelters(_ province: Province) async throws -> [SigunguDTO: [ShelterDTO]]
}
