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

    private(set) var kind = [Upkind: [KindDTO]]()
    private(set) var sido = [SidoDTO]()    // MAYBE: - 1안, Dictionary로 빼기, 2안 Sido안에 Sigungu, Shelter를 포함한 새로운 Entity를 제작
    private(set) var province = [SidoDTO: [SigunguDTO]]()
    private(set) var shelter = [SigunguDTO: [ShelterDTO]]()

    init(service: SearchService) {
        self.service = service

        Task { await self.loadInfos() }
    }

    public func loadInfos() async {
        do {
            self.kind = try await FetchKind(service: service).execute(by: Upkind.allCases)
        } catch {
            print("failed at fetching kind using by upkind")
            print(error.localizedDescription)
        }

        do {
            self.sido = try await FetchSido(service: service).execute().results
        } catch {
            print("failed at fetching sido")
            print(error.localizedDescription)
        }

        self.province = await FetchSigungu(service: service).execute(by: sido)
        self.shelter = await FetchShelter(service: service).execute(by: province)
    }
}
