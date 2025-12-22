//
//  LoadPrerequisiteDataUseCase.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//

import Foundation

final class LoadMetaDataUseCase {
    private let metadataRepository: MetadataRepository

    init(metadataRepository: MetadataRepository) {
        self.metadataRepository = metadataRepository
    }

    // 초기 로딩: kind, sido, province
    func execute() async -> Result<ProvinceMetadata, Error> {
        do {
            async let kindTask = metadataRepository.fetchKinds()
            async let sidoTask = metadataRepository.fetchSidos()

            let (kind, sido) = try await (kindTask, sidoTask)
            let province = try await metadataRepository.fetchProvinces(sido)

            let data = ProvinceMetadata(
                kind: kind,
                sido: sido,
                province: province
            )

            return .success(data)
        } catch {
            return .failure(error)
        }
    }

    // 특정 시군구의 shelter만 로드
    func fetchSheltersForSigungu(sido: String, sigungu: String) async -> Result<[ShelterEntity], Error> {
        do {
            let shelters = try await metadataRepository.fetchShelter(sido, sigungu)
            return .success(shelters)
        } catch {
            return .failure(error)
        }
    }
}
