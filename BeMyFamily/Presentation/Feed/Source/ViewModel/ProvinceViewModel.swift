//
//  ProvinceViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 4/30/24.
//

import Foundation

@Observable
final class ProvinceViewModel: ObservableObject {
    private let service: SearchService

    private(set) var kind = [Upkind: [Kind]]()
    private(set) var sido = [Sido]()    // MAYBE: - 1안, Dictionary로 빼기, 2안 Sido안에 Sigungu, Shelter를 포함한 새로운 Entity를 제작
    private(set) var province = [Sido: [Sigungu]]()
    private(set) var shelter = [Sigungu: [Shelter]]()

    init(service: SearchService) {
        self.service = service

        Task { await self.loadInfos() }
    }

    public func loadInfos() async {
        do {
            self.kind = try await Actions.FetchKind(service: service).execute(by: Upkind.allCases)
        } catch {
            print("failed at fetching kind using by upkind")
        }

        do {
            self.sido = try await Actions.FetchSido(service: service).execute().results
        } catch {
            print("failed at fetching sido")
        }

        do {
            self.province = try await Actions.FetchSigungu(service: service).execute(by: sido)
        } catch {
            print("failed at fetching province")
        }

        do {
            self.shelter = try await Actions.FetchShelter(service: service).execute(by: province)
        } catch {
            print("failed at fetching shelter")
        }

    }
}
