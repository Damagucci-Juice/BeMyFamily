//
//  MetadataRepositoryImpl.swift
//  BeMyFamily
//
//  Created by Gucci on 12/21/25.
//

import Foundation

final class MetadataRepositoryImpl: MetadataRepository {
    private let service: SearchService

    init(service: SearchService) {
        self.service = service
    }

    func fetchKinds() async throws -> [Upkind : [KindEntity]] {
        try await withThrowingTaskGroup(of: (Upkind, [KindEntity]).self) { group in
            for upkind in Upkind.allCases {
                group.addTask {
                    (upkind, try await self.fetchKind(upkind.id))
                }
            }

            return try await group.reduce(into: [Upkind: [KindEntity]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
    
    func fetchSidos() async throws -> [SidoEntity] {
        let fetched = try await service.search(.sido)
        return try setSido(fetched)
    }
    
    func fetchProvinces(_ sidos: [SidoEntity]) async throws -> Province {
        await withTaskGroup(of: (SidoEntity, [SigunguEntity]).self) { group in
            for sido in sidos {
                group.addTask {
                    let results = await self.fetchSigungu(sido)
                    return (sido, results)
                }
            }

            return await group.reduce(into: [SidoEntity: [SigunguEntity]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
    
    func fetchShelters(_ province: Province) async throws -> [SigunguEntity : [ShelterEntity]] {
        await withTaskGroup(of: (SigunguEntity, [ShelterEntity]).self) { group in
            for (sido, sigungus) in province {
                for sigungu in sigungus {
                    group.addTask { [unowned self] in
                        let results = await self.fetchShelter(sido.id, sigungu.id)
                        return (sigungu, results)
                    }
                }
            }

            return await group
                .reduce(into: [SigunguEntity: [ShelterEntity]]()) { dict, pair in
                dict[pair.0] = pair.1
            }
        }
    }
}

private extension MetadataRepositoryImpl {
    func setSido(_ data: Data) throws -> [SidoEntity] {
        return try JSONDecoder()
            .decode(
                APIResponse<SidoDTO>.self,
                from: data
            )
            .items
            .compactMap({
                Mapper.sidoDto2Entity($0)
            })
    }

    func fetchSigungu(_ entity: SidoEntity) async -> [SigunguEntity] {
        do {
            let fetched = try await service.search(.sigungu(sido: entity.id))
            return try setSigungu(fetched)
        } catch {
            // ex) 세종특별자치시
            print("Error: \(entity.id)_\(entity.name) 데이터를 가져오거나 디코딩하는 데 실패함, response items가 빈 경우도 있음")
            return []
        }
    }

    func setSigungu(_ data: Data) throws -> [SigunguEntity] {
        return try JSONDecoder()
            .decode(
                APIResponse<SigunguDTO>.self,
                from: data
            )
            .items
            .compactMap({
                Mapper.sigunguDto2Entity($0)
            })
    }

    func fetchShelter(_ sidoId: String, _ sigunguId: String) async -> [ShelterEntity] {
        do {
            let fetched = try await service
                .search(.shelter(sido: sidoId, sigungu: sigunguId))
            return try setShelter(fetched)
        } catch {
            return []
        }
    }

    func setShelter(_ data: Data) throws -> [ShelterEntity] {
        let apiResponse: APIResponse<ShelterDTO> = try JSONDecoder()
            .decode(APIResponse<ShelterDTO>.self, from: data)
        return apiResponse.items.map(Mapper.shelterDto2Entity)
    }

    func fetchKind(_ upKindId: String) async throws -> [KindEntity] {
        let fetched = try await service.search(.kind(upkind: upKindId))
        return try setKind(fetched)
    }

    func setKind(_ data: Data) throws -> [KindEntity] {
        let apiResponse: APIResponse<KindDTO> = try JSONDecoder()
            .decode(APIResponse<KindDTO>.self, from: data)
        return apiResponse.items.map(Mapper.kindDto2Entity)
    }
}
