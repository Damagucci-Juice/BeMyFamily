//
//  Actions.swift
//  BeMyFamily
//
//  Created by Gucci on 4/13/24.
//
//
import Foundation

struct Actions {
    struct FetchSido: AsyncAction {
        let service: SearchService

        public func execute() async throws -> Response<Sido> {
            let fetched = try await service.search(.sido)
            return try SetSido(data: fetched).excute()
        }
    }

    struct SetSido: Action {
        let data: Data

        func excute() throws -> Response<Sido> {
            do {
                let response = try JSONDecoder().decode(APIResponse<Sido>.self, from: data)
                return Response(results: response.items)
            } catch {
                throw error
            }
        }
    }

    struct FetchSigungu: AsyncAction {
        let service: SearchService

        private func execute(_ sidoCode: String) async -> Response<Sigungu> {
            let fetched: Data
            do {
                fetched = try await service.search(.sigungu(sido: sidoCode))
            } catch {
                print("에러코드: \(sidoCode), 해당 시도에 대한 데이터를 가져오지 못했습니다.")
                return Response(results: [])
            }

            do {
                return try SetSigungu(data: fetched).excute()
            } catch {
                print("에러코드: \(sidoCode), 해당 시도에 속한 시군구 데이터를 디코딩하지 못함")
                return Response(results: [])
            }
        }

        public func execute(by sidos: [Sido]) async -> [Sido: [Sigungu]] {
            await withTaskGroup(of: (Sido, [Sigungu]).self) { group in
                for sido in sidos {
                    group.addTask {
                        let fetchedSigungu = await execute(sido.id).results
                        return (sido, fetchedSigungu)
                    }
                }

                var sigungus = [Sido: [Sigungu]]()

                for await (eachSido, fetchedSigungu) in group {
                    sigungus[eachSido] = fetchedSigungu
                }

                return sigungus
            }
        }
    }

    struct SetSigungu: Action {
        let data: Data

        func excute() throws -> Response<Sigungu> {
            do {
                let response = try JSONDecoder().decode(APIResponse<Sigungu>.self, from: data)
                return Response(results: response.items)
            } catch {
                throw error
            }
        }
    }

    struct FetchShelter: AsyncAction {
        let service: SearchService

        private func execute(_ sidoCode: String, _ sigunguCode: String) async -> [Shelter] {
            let fetched: Data
            do {
                fetched = try await service.search(.shelter(sido: sidoCode, sigungu: sigunguCode))
            } catch {
                return []
            }

            do {
                return try SetShelter(data: fetched).excute().results
            } catch {
                return []
            }
        }

        public func execute(by province: [Sido: [Sigungu]]) async -> [Sigungu: [Shelter]] {
            await withTaskGroup(of: (Sigungu, [Shelter]).self) { group in
                for (sido, sigungus) in province {
                    for eachSigungu in sigungus {
                        group.addTask {
                            let fetchedShelter = await execute(sido.id, eachSigungu.id)
                            return (eachSigungu, fetchedShelter)
                        }
                    }
                }

                var shelters = [Sigungu: [Shelter]]()

                for await (eachSigungu, fetchedShelter) in group {
                    shelters[eachSigungu] = fetchedShelter
                }

                return shelters
            }
        }
    }

    struct SetShelter: Action {
        let data: Data

        public func excute() throws -> Response<Shelter> {
            do {
                let shelterResponse = try JSONDecoder().decode(APIResponse<Shelter>.self, from: data)
                return Response(results: shelterResponse.items)
            } catch {
                throw error
            }
        }
    }

    struct FetchKind: AsyncAction {
        let service: SearchService

        private func execute(_ upkindCode: String) async throws -> [Kind] {
            let fetched = try await service.search(.kind(upkind: upkindCode))
            do {
                return try SetKind(data: fetched).excute().results
            } catch {
                print("축종코드: \(upkindCode), 해당 축종의 정보를 디코딩하지 못했습니다.")
                throw error
            }
        }

        public func execute(by upkinds: [Upkind]) async throws -> [Upkind: [Kind]] {
            try await withThrowingTaskGroup(of: (Upkind, [Kind]).self) { group in
                for upkind in upkinds {
                    group.addTask {
                        let fetchedKind = try await execute(upkind.id)
                        return (upkind, fetchedKind)
                    }
                }
                var kinds = [Upkind: [Kind]]()

                for try await (upkind, fetchedKind) in group {
                    kinds[upkind] = fetchedKind
                }

                return kinds
            }
        }
    }

    struct SetKind: Action {
        let data: Data

        func excute() throws -> Response<Kind> {
            do {
                let sigunguResponse = try JSONDecoder().decode(APIResponse<Kind>.self, from: data)
                return Response(results: sigunguResponse.items)
            } catch {
                throw error
            }
        }
    }

    struct FetchAnimal: AsyncAction {
        let service: SearchService
        let filter: AnimalFilter
        let page: Int

        public func execute() async throws -> [Animal] {
            let fetched = try await service.search(.animal(filteredItem: filter, page: page))
            return try SetAnimal(data: fetched).excute().results
        }
    }

    struct SetAnimal: Action {
        let data: Data

        public func excute() throws -> Response<Animal> {
            do {
                let animalResponse = try JSONDecoder().decode(APIResponse<Animal>.self, from: data)
                return Response(results: animalResponse.items)
            } catch {
                throw error
            }
        }
    }
}

protocol Action { }
protocol AsyncAction: Action { }
