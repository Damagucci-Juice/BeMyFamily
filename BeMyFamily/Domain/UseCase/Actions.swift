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
    typealias Payload = SidoDTO
    let data: Data = Data() // 프로토콜 준수를 위한 더미 (실제로는 사용 X)
    let service: SearchService

    func execute() async throws -> Response<SidoDTO> {
        let fetched = try await service.search(.sido)
        return try SetSido(data: fetched).execute()
    }
}

struct SetSido: Action {
    typealias Payload = SidoDTO
    let data: Data
    func execute() throws -> Response<SidoDTO> { try decode() }
}

// MARK: - Sigungu
struct FetchSigungu: AsyncAction {
    typealias Payload = SigunguDTO
    let data: Data = Data()
    let service: SearchService

    private func fetchSingle(by sidoCode: String) async -> [SigunguDTO] {
        do {
            let fetched = try await service.search(.sigungu(sido: sidoCode))
            return try SetSigungu(data: fetched).execute().results
        } catch {
            print("Error: \(sidoCode) 데이터를 가져오거나 디코딩하는 데 실패함, response items가 빈 경우도 있음")
            return []
        }
    }

    public func execute(by sidos: [SidoDTO]) async -> [SidoDTO: [SigunguDTO]] {
        await withTaskGroup(of: (SidoDTO, [SigunguDTO]).self) { group in
            for sido in sidos {
                group.addTask {
                    let results = await fetchSingle(by: sido.id)
                    return (sido, results)
                }
            }

            return await group.reduce(into: [SidoDTO: [SigunguDTO]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
}

struct SetSigungu: Action {
    typealias Payload = SigunguDTO
    let data: Data
    func execute() throws -> Response<SigunguDTO> { try decode() }
}

// MARK: - Shelter
struct FetchShelter: AsyncAction {
    typealias Payload = ShelterDTO
    let data: Data = Data()
    let service: SearchService

    private func fetchSingle(_ sidoCode: String, _ sigunguCode: String) async -> [ShelterDTO] {
        do {
            let fetched = try await service.search(.shelter(sido: sidoCode, sigungu: sigunguCode))
            return try SetShelter(data: fetched).execute().results
        } catch {
            return []
        }
    }

    public func execute(by province: [SidoDTO: [SigunguDTO]]) async -> [SigunguDTO: [ShelterDTO]] {
        await withTaskGroup(of: (SigunguDTO, [ShelterDTO]).self) { group in
            for (sido, sigungus) in province {
                for sigungu in sigungus {
                    group.addTask {
                        let results = await fetchSingle(sido.id, sigungu.id)
                        return (sigungu, results)
                    }
                }
            }

            return await group.reduce(into: [SigunguDTO: [ShelterDTO]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
}

struct SetShelter: Action {
    typealias Payload = ShelterDTO
    let data: Data
    func execute() throws -> Response<ShelterDTO> { try decode() }
}

// MARK: - Kind (Animal Type)
struct FetchKind: AsyncAction {
    typealias Payload = KindDTO
    let data: Data = Data()
    let service: SearchService

    private func fetchSingle(_ upkindCode: String) async throws -> [KindDTO] {
        let fetched = try await service.search(.kind(upkind: upkindCode))
        return try SetKind(data: fetched).execute().results
    }

    public func execute(by upkinds: [Upkind]) async throws -> [Upkind: [KindDTO]] {
        try await withThrowingTaskGroup(of: (Upkind, [KindDTO]).self) { group in
            for upkind in upkinds {
                group.addTask {
                    (upkind, try await fetchSingle(upkind.id))
                }
            }

            return try await group.reduce(into: [Upkind: [KindDTO]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
}

struct SetKind: Action {
    typealias Payload = KindDTO
    let data: Data
    func execute() throws -> Response<KindDTO> { try decode() }
}

// MARK: - Animal
struct FetchAnimal: AsyncAction {
    typealias Payload = AnimalDTO
    let data: Data = Data()
    let service: SearchService
    let filter: AnimalSearchFilter
    let page: Int

    func execute() async throws -> [AnimalDTO] {
        let fetched = try await service.search(.animal(filteredItem: filter, page: page))
        return try SetAnimal(data: fetched).execute().results
    }
}

struct SetAnimal: Action {
    typealias Payload = AnimalDTO
    let data: Data
    func execute() throws -> Response<AnimalDTO> { try decode() }
}
