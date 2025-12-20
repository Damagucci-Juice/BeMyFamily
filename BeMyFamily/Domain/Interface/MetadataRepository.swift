//
//  MetadataRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//

import Foundation

protocol MetadataRepository {
    func getKinds() async throws -> [Upkind: [Kind]]
    func getSidos() async throws -> [Sido]
    func getProvinces(_ sidos: [Sido]) async throws -> Province
    func getShelters(_ province: Province) async throws -> [Sigungu: [Shelter]]
}
