//
//  FavoriteAnimalRepositoryImpl.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

final class FavoriteRepositoryImpl: FavoriteRepository {
    private let storage: FavoriteStorage

    init(storage: FavoriteStorage) {
        self.storage = storage
    }

    func save(_ animal: AnimalEntity) {
        storage.add(animal: Mapper.animalEntity2Dto(animal))
    }

    func delete(id: String) {
        storage.remove(id)
    }

    func getAll() -> [AnimalEntity] {
        storage.list()
            .map(Mapper.animalDto2Entity)
            .map { entity in
                var updatedEntity = entity
                updatedEntity.updateFavoriteStatus(true)
                return updatedEntity
            }
    }

    func getIds() -> Set<String> {
        Set(storage.list().map { String($0.id) })
    }

    func exists(id: String) -> Bool {
        storage.contains(id)
    }
}
