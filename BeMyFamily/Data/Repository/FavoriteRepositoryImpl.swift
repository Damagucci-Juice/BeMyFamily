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

    func save(_ animal: Animal) {
        storage.add(animal: animal)
    }

    func delete(id: String) {
        storage.remove(id)
    }

    func getAll() -> [Animal] {
        storage.list()
    }

    func getIds() -> Set<String> {
        Set(storage.list().map { String($0.id) })
    }

    func exists(id: String) -> Bool {
        storage.contains(id)
    }
}
