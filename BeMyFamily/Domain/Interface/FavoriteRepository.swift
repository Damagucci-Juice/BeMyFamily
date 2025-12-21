//
//  FavoriteAnimalRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

protocol FavoriteRepository {
    func save(_ animal: AnimalEntity)
    func delete(id: String)
    func getAll() -> [AnimalEntity]
    func getIds() -> Set<String>
    func exists(id: String) -> Bool
}
