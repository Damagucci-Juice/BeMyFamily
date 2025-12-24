//
//  MockData.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//

import Foundation

@Observable
final class ModelData {
    private let fileType = "json"
    private let fileReadError = "File not readable"
    private let fileNotFoundError = "File not found"

    var sido: PaginatedAPIResponse<Sido> = load(Constants.TestFile.sido)
    var sigungu: APIResponse<Sigungu> = load(Constants.TestFile.sigungu)
    var kind: APIResponse<Kind> = load(Constants.TestFile.kind)
    var shelter: APIResponse<Shelter> = load(Constants.TestFile.shelter)
    var emptyShelter: APIResponse<Shelter> = load(Constants.TestFile.emptyShelter)
    var animals: PaginatedAPIResponse<Animal> = load(Constants.TestFile.animal)
    var emptyAnimals: PaginatedAPIResponse<Animal> = load(Constants.TestFile.emptyAnimal)
}

func load<T: Decodable>(_ filename: String) -> T {
    let data = loadData(filename)

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        dump(data.prettyPrintedJSONString)
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

func loadData(_ filename: String) -> Data {
    let data: Data
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    return data
}
