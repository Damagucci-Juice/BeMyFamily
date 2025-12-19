//
//  FavoriteAnimalRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

protocol FavoriteAnimalRepository {
    func saveFavoriteAnimal(animal: Animal)
    func removeFavoriteAnimal(animal: Animal)
    func loadFavoriteAnimlaList() -> [Animal]
    func contains(animal: Animal) -> Bool 
}
