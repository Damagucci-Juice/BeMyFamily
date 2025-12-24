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
            .search(.animal(filteredItem: filter, page: pageNo))
        return try setAnimal(fetched)
    }

    private func setAnimal(_ data: Data) throws -> ([AnimalEntity], Paging) {
        let apiResponse = try JSONDecoder().decode(APIResponse<AnimalDTO>.self, from: data)
        let animalEntities = apiResponse.items.map(Mapper.animalDto2Entity)
        let page = Paging(apiResponse)
        return (animalEntities, page)
    }

    func refreshAnimals(filter: AnimalSearchFilter) async throws -> [AnimalEntity] {
        []
    }
}
