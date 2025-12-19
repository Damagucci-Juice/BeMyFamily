//
//  MockFamilyService.swift
//  BeMyFamily
//
//  Created by Gucci on 5/10/24.
//

import Foundation

final class MockFamilyService: SearchService {
    let isEmptyResultTest: Bool
    init(isEmptyResultTest: Bool = false) {
        self.isEmptyResultTest = isEmptyResultTest
    }

    func search(_ endpoint: FamilyEndpoint) async throws -> Data {
        try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...500_000_000))

        let fileName: String

        switch endpoint {
        case .sido:
            fileName = NetworkConstants.TestFile.sido
        case .sigungu:
            fileName = NetworkConstants.TestFile.sigungu
        case .kind:
            fileName = NetworkConstants.TestFile.kind
        case .shelter:
            fileName = isEmptyResultTest ? NetworkConstants.TestFile.emptyShelter : NetworkConstants.TestFile.shelter
        case .animal:
            fileName = isEmptyResultTest ? NetworkConstants.TestFile.emptyAnimal : NetworkConstants.TestFile.animal
        }

        return loadData(fileName)
    }

    func performRequest(urlRequest: URLRequest) async throws -> Data {
        return Data()
    }
}
