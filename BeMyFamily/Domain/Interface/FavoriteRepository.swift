//
//  FavoriteAnimalRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

protocol FavoriteRepository {
    func save(_ animal: Animal)
    func delete(id: String)
    func getAll() -> [Animal]
    func getIds() -> Set<String>
    func exists(id: String) -> Bool
}
