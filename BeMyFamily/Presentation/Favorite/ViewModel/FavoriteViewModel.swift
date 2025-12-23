//
//  FavoriteViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import Foundation
import Observation

@Observable
final class FavoriteViewModel {
    private let repo: FavoriteRepository

    init(repository: FavoriteRepository) {
        self.repo = repository
        didOnAppear()
    }

    var favorites: [AnimalEntity] = []

    func didOnAppear() {
        favorites = repo.getAll()
    }
}
