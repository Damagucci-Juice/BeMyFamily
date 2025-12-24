//
//  FilterViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 4/26/24.
//

import Foundation
import Observation

@Observable
final class FilterViewModel {
    private let useCase: LoadMetaDataUseCase

    // MARK: - Metadata
    private(set) var metadata: ProvinceMetadata?
    var isLoading: Bool = false
    var error: Error?

    // MARK: - Shelter 지연 로딩
    private var shelterCache: [SigunguEntity: [ShelterEntity]] = [:]
    var isLoadingShelters: Bool = false

    // MARK: - Filter Properties
    var beginDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var endDate: Date = Date()
    var upkind: Upkind?
    var kinds: Set<KindEntity> = []
    var sido: SidoEntity?
    var sigungu: SigunguEntity? {
        didSet {
            shelter = nil
            if let sigungu = sigungu, let sido = sido {
                Task {
                    await loadSheltersIfNeeded(sido: sido.id, sigungu: sigungu)
                }
            }
        }
    }
    var shelter: ShelterEntity?
    var state: ProcessState = .all
    var neutral: Neutralization?

    init(useCase: LoadMetaDataUseCase) {
        self.useCase = useCase

        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            if let metadata = await self.loadMetadataIfNeeded() {
                self.metadata = metadata
            } else {
                self.error = NSError(domain: "Failed to load metadata", code: 0, userInfo: nil)
            }
            self.isLoading = false
        }

    }

    private func loadMetadataIfNeeded() async -> ProvinceMetadata? {
        if let cachedMeta = DIContainer.shared.resolveSingleton(ProvinceMetadata.self) {
            return cachedMeta
        }

        if let fetchedMeta = try? await useCase.execute().get() {
            return fetchedMeta
        }

        return nil
    }

    private func loadSheltersIfNeeded(sido: String, sigungu: SigunguEntity) async {
        guard shelterCache[sigungu] == nil else { return }
        isLoadingShelters = true
        let result = await useCase.fetchSheltersForSigungu(sido: sido, sigungu: sigungu.id)
        isLoadingShelters = false

        if case .success(let shelters) = result {
            shelterCache[sigungu] = shelters
        }
    }

    func getSheltersForCurrentSigungu() -> [ShelterEntity] {
        guard let sigungu = sigungu else { return [] }
        return shelterCache[sigungu] ?? []
    }

    func reset() {
        beginDate = beginDate
        endDate = endDate
        upkind = nil
        kinds.removeAll()
        sido = nil
        sigungu = nil
        shelter = nil
        state = .all
        neutral = nil
    }

    func makeFilters() -> [AnimalSearchFilter] {
        // ✅ kinds가 비어있으면 하나의 기본 필터 생성
        if kinds.isEmpty {
            let filter = AnimalSearchFilter(
                beginDate: beginDate,
                endDate: endDate,
                upkind: upkind?.id,  // 축종만 선택한 경우
                kind: nil,            // 품종 미선택
                sido: sido?.id,
                sigungu: sigungu?.id,
                shelterNumber: shelter?.id,
                processState: state.param,
                neutralizationState: neutral?.id
            )
            return [filter]
        }

        // ✅ kinds가 있으면 각 품종별 필터 생성
        return kinds.map { kind in
            AnimalSearchFilter(
                beginDate: beginDate,
                endDate: endDate,
                upkind: upkind?.id,
                kind: kind.id,
                sido: sido?.id,
                sigungu: sigungu?.id,
                shelterNumber: shelter?.id,
                processState: state.param,
                neutralizationState: neutral?.id
            )
        }
    }

    func kinds(_ upKind: Upkind) -> [KindEntity] {
        if let kinds = metadata?.kind[upKind, default: []] {
            return kinds
        }
        return []
    }

    func sidos() -> [SidoEntity] {
        if let sidos = metadata?.sido {
            return sidos
        }
        return []
    }

    func sigungus() -> [SigunguEntity] {
        if let sido = sido,
           let sigungus = metadata?.province[sido, default: []] {
            return sigungus
        }
        
        return []
    }

    func toggleKind(_ kind: KindEntity) {
        if isSelected(kind) {
            kinds.remove(kind)
        } else {
            kinds.insert(kind)
        }
    }

    func isSelected(_ kind: KindEntity) -> Bool {
        kinds.contains(kind)
    }

    func allKinds() -> [Upkind: [KindEntity]] {
        if let kinds = metadata?.kind {
            return kinds
        }
        return [:]
    }
}
