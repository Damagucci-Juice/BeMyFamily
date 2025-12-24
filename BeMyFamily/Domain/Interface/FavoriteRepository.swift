//
//  FavoriteAnimalRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation
import Combine

protocol FavoriteRepository {
    func toggle(_ animal: AnimalEntity)
    func getAll() -> [AnimalEntity]
    func getIds() -> Set<String>

    var favoriteIdsPublisher: AnyPublisher<Set<String>, Never> { get }
}
