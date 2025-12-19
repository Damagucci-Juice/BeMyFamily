//
//  UserDefaultsFavoriteStorage.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

protocol FavoriteStorage {
    func add(animal: Animal)
    func remove(_ id: String)
    func contains(_ id: String) -> Bool
    func list() -> [Animal]
}

class UserDefaultsFavoriteStorage: FavoriteStorage {
    private let databaseKey = NetworkConstants.Path.dataBase

    init() {
        // Ensure the UserDefaults contains a valid array at initialization
        if UserDefaults.standard.object(forKey: databaseKey) == nil {
            UserDefaults.standard.set([Animal](), forKey: databaseKey)
        }
    }

    private func set() -> Set<Animal> {
        // Retrieve and decode the array of favorite IDs from UserDefaults, converting to a Set
        if let data = UserDefaults.standard.object(forKey: NetworkConstants.Path.dataBase) as? Data {
            let decoder = JSONDecoder()
            if let loadedAnimals = try? decoder.decode([Animal].self, from: data) {
                return Set(loadedAnimals)
            }
        }
        return Set<Animal>()
    }

    private func update(_ favorites: Set<Animal>) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: NetworkConstants.Path.dataBase)
        }
    }

    func add(animal: Animal) {
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

    func list() -> [Animal] {
        let favorites = set()
        return Array(favorites).sorted(by: { $0.happenDt > $1.happenDt })
    }
}
