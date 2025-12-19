//
//  Actions.swift
//  BeMyFamily
//
//  Created by Gucci on 4/13/24.
//
//
import Foundation

protocol Action {
    associatedtype Payload: Codable
    var data: Data { get }
}

extension Action {
    // 모든 Set 액션들이 공유할 공통 디코딩 로직
    func decode() throws -> Response<Payload> {
        let response = try JSONDecoder().decode(APIResponse<Payload>.self, from: data)
        return Response(results: response.items)
    }
}

protocol AsyncAction: Action { }

// MARK: - Sido
struct FetchSido: AsyncAction {
    typealias Payload = Sido
    let data: Data = Data() // 프로토콜 준수를 위한 더미 (실제로는 사용 X)
    let service: SearchService

    func execute() async throws -> Response<Sido> {
        let fetched = try await service.search(.sido)
        return try SetSido(data: fetched).execute()
    }
}

struct SetSido: Action {
    typealias Payload = Sido
    let data: Data
    func execute() throws -> Response<Sido> { try decode() }
}

// MARK: - Sigungu
struct FetchSigungu: AsyncAction {
    typealias Payload = Sigungu
    let data: Data = Data()
    let service: SearchService

    private func fetchSingle(by sidoCode: String) async -> [Sigungu] {
        do {
            let fetched = try await service.search(.sigungu(sido: sidoCode))
            return try SetSigungu(data: fetched).execute().results
        } catch {
            print("Error: \(sidoCode) 데이터를 가져오거나 디코딩하는 데 실패함, response items가 빈 경우도 있음")
            return []
        }
    }

    public func execute(by sidos: [Sido]) async -> [Sido: [Sigungu]] {
        await withTaskGroup(of: (Sido, [Sigungu]).self) { group in
            for sido in sidos {
                group.addTask {
                    let results = await fetchSingle(by: sido.id)
                    return (sido, results)
                }
            }

            return await group.reduce(into: [Sido: [Sigungu]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
}

struct SetSigungu: Action {
    typealias Payload = Sigungu
    let data: Data
    func execute() throws -> Response<Sigungu> { try decode() }
}

// MARK: - Shelter
struct FetchShelter: AsyncAction {
    typealias Payload = Shelter
    let data: Data = Data()
    let service: SearchService

    private func fetchSingle(_ sidoCode: String, _ sigunguCode: String) async -> [Shelter] {
        do {
            let fetched = try await service.search(.shelter(sido: sidoCode, sigungu: sigunguCode))
            return try SetShelter(data: fetched).execute().results
        } catch {
            return []
        }
    }

    public func execute(by province: [Sido: [Sigungu]]) async -> [Sigungu: [Shelter]] {
        await withTaskGroup(of: (Sigungu, [Shelter]).self) { group in
            for (sido, sigungus) in province {
                for sigungu in sigungus {
                    group.addTask {
                        let results = await fetchSingle(sido.id, sigungu.id)
                        return (sigungu, results)
                    }
                }
            }

            return await group.reduce(into: [Sigungu: [Shelter]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
}

struct SetShelter: Action {
    typealias Payload = Shelter
    let data: Data
    func execute() throws -> Response<Shelter> { try decode() }
}

// MARK: - Kind (Animal Type)
struct FetchKind: AsyncAction {
    typealias Payload = Kind
    let data: Data = Data()
    let service: SearchService

    private func fetchSingle(_ upkindCode: String) async throws -> [Kind] {
        let fetched = try await service.search(.kind(upkind: upkindCode))
        return try SetKind(data: fetched).execute().results
    }

    public func execute(by upkinds: [Upkind]) async throws -> [Upkind: [Kind]] {
        try await withThrowingTaskGroup(of: (Upkind, [Kind]).self) { group in
            for upkind in upkinds {
                group.addTask {
                    (upkind, try await fetchSingle(upkind.id))
                }
            }

            return try await group.reduce(into: [Upkind: [Kind]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
}

struct SetKind: Action {
    typealias Payload = Kind
    let data: Data
    func execute() throws -> Response<Kind> { try decode() }
}

// MARK: - Animal
struct FetchAnimal: AsyncAction {
    typealias Payload = Animal
    let data: Data = Data()
    let service: SearchService
    let filter: AnimalFilter
    let page: Int

    func execute() async throws -> [Animal] {
        let fetched = try await service.search(.animal(filteredItem: filter, page: page))
        return try SetAnimal(data: fetched).execute().results
    }
}

struct SetAnimal: Action {
    typealias Payload = Animal
    let data: Data
    func execute() throws -> Response<Animal> { try decode() }
}
