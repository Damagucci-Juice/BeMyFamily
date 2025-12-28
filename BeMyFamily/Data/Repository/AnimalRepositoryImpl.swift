//
//  AnimalRepositoryImpl.swift
//  BeMyFamily
//
//  Created by Gucci on 12/21/25.
//
import Foundation

final class AnimalRepositoryImpl: AnimalRepository {
    private let service: SearchService

    init(service: SearchService) {
        self.service = service
    }

    func getAnimals(filter: AnimalSearchFilter, pageNo: Int) async throws -> ([AnimalEntity], Paging) {
        let fetched = try await service
            .search(.animals(filteredItem: filter, page: pageNo))
        return try setAnimals(fetched)
    }

    private func setAnimals(_ data: Data) throws -> ([AnimalEntity], Paging) {
        let apiResponse = try JSONDecoder().decode(APIResponse<AnimalDTO>.self, from: data)
        let animalEntities = apiResponse.items.map(Mapper.animalDto2Entity)
        let page = Paging(apiResponse)
        return (animalEntities, page)
    }

    func refreshAnimals(filter: AnimalSearchFilter) async throws -> [AnimalEntity] {
        []
    }

    func fetchAnAnimal(id: String) async throws -> AnimalEntity {
        let fetched = try await service.search(.anAnimal(id))
        return try setAnimal(fetched)
    }

    private func setAnimal(_ data: Data) throws -> AnimalEntity {
        let apiResponse = try JSONDecoder().decode(APIResponse<AnimalDTO>.self, from: data)
        let animalEntities = apiResponse.items.map(Mapper.animalDto2Entity)
        if let result = animalEntities.first {
            return result
        } else {
            throw NSError(domain: "Set An Aniaml Error", code: 404)
        }
    }
}
