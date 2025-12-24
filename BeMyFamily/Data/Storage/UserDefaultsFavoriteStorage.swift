//
//  UserDefaultsFavoriteStorage.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

protocol FavoriteStorage {
    func add(animal: AnimalDTO)
    func remove(_ id: String)
    func contains(_ id: String) -> Bool
    func list() -> [AnimalDTO]
}

final class UserDefaultsFavoriteStorage: FavoriteStorage {
    private let databaseKey = NetworkConstants.Path.dataBase

    static let shared = UserDefaultsFavoriteStorage()

    private init() {
        // Ensure the UserDefaults contains a valid array at initialization
        if UserDefaults.standard.object(forKey: databaseKey) == nil {
            UserDefaults.standard.set([AnimalDTO](), forKey: databaseKey)
        }
    }

    private func set() -> Set<AnimalDTO> {
        // Retrieve and decode the array of favorite IDs from UserDefaults, converting to a Set
        if let data = UserDefaults.standard.object(forKey: NetworkConstants.Path.dataBase) as? Data {
            let decoder = JSONDecoder()
            if let loadedAnimals = try? decoder.decode([AnimalDTO].self, from: data) {
                return Set(loadedAnimals)
            }
        }
        return Set<AnimalDTO>()
    }

    private func update(_ favorites: Set<AnimalDTO>) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: NetworkConstants.Path.dataBase)
        }
    }

    func add(animal: AnimalDTO) {
        var favorites = set()
        favorites.insert(animal)
        update(favorites)
    }

    func remove(_ id: String) {
        update(set().filter { $0.id != id })
    }

    func contains(_ id: String) -> Bool {
        return set().contains { $0.id == id }
    }

    func list() -> [AnimalDTO] {
        let favorites = set()
        return Array(favorites).sorted(by: { $0.happenDt > $1.happenDt })
    }
}
