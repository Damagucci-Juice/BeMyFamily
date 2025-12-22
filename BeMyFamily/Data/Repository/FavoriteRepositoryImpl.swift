//
//  FavoriteAnimalRepositoryImpl.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation
import Combine

final class FavoriteRepositoryImpl: FavoriteRepository {
    private let storage: FavoriteStorage

    private let favoriteIdsSubject: CurrentValueSubject<Set<String>, Never>

    var favoriteIdsPublisher: AnyPublisher<Set<String>, Never> {
        favoriteIdsSubject.eraseToAnyPublisher()
    }

    init(storage: FavoriteStorage) {
        self.storage = storage

        // 초기 값 설정
        let initialIds = Set(storage.list().map { String($0.id) })
        self.favoriteIdsSubject = CurrentValueSubject(initialIds)
    }

    func toggle(_ animal: AnimalEntity) {
        if storage.contains(animal.id) {
            storage.remove(animal.id)
        } else {
            storage.add(animal: Mapper.animalEntity2Dto(animal))
        }

        // 변경사항을 알림
        let updatedIds = Set(storage.list().map { String($0.id) })
        favoriteIdsSubject.send(updatedIds)
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
        favoriteIdsSubject.value
    }
}
