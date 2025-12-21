//
//  FavoriteTabViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import Foundation
import Observation

@Observable
final class FavoriteTabViewModel {
    private let getFavoriteAnimalsUseCase: GetFavoriteAnimalsUseCase

    init(getFavoriteAnimalsUseCase: GetFavoriteAnimalsUseCase) {
        self.getFavoriteAnimalsUseCase = getFavoriteAnimalsUseCase
        didOnAppear()
    }

    var favorites: [AnimalEntity] = []

    func didOnAppear() {
        favorites = getFavoriteAnimalsUseCase.excute()
    }
}
