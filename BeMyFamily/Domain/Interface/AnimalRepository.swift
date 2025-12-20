//
//  AnimalRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//
import Foundation

protocol AnimalRepository {
    func getAnimals(
        filter: AnimalSearchFilter,
        pageNo: Int
    ) async throws -> [AnimalDTO]
    
    func refreshAnimals(filter: AnimalSearchFilter) async throws -> [AnimalDTO]
}
