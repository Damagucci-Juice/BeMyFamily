//
//  LoadPrerequisiteDataUseCase.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//
import Foundation

final class LoadPrerequisiteDataUseCase {
    private let metadataRepository: MetadataRepository

    init(metadataRepository: MetadataRepository) {
        self.metadataRepository = metadataRepository
    }

    func execute() async -> Result<PrerequisiteData, Error> {
        do {
            let kind        = try await metadataRepository.fetchKinds()
            let sido        = try await metadataRepository.fetchSidos()
            let province    = try await metadataRepository.fetchProvinces(sido)
            let shelter     = try await metadataRepository.fetchShelters(province)

            let data = PrerequisiteData(
                kind: kind,
                sido: sido,
                province: province,
                shelter: shelter
            )

            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}
