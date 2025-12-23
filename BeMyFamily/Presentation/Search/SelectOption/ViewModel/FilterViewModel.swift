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

    var onSearchCompleted: (([AnimalSearchFilter]) -> Void)?

    // MARK: - Metadata
    var metadata: ProvinceMetadata?
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
            shelter = nil // 시군구 변경 시 shelter 초기화

            // 시군구 선택 시 해당 shelter 로드
            if let sigungu = sigungu, let sido = sido {
                Task {
                    await loadSheltersIfNeeded(sido: sido.id, sigungu: sigungu)
                }
            }
        }
    }
    var shelter: ShelterEntity?

    var state: ProcessState = .notice
    var neutral: Neutralization?

    init(useCase: LoadMetaDataUseCase) {
        self.useCase = useCase
    }

    // 초기 메타데이터 로드 (kind, sido, province만)
    func loadMetadataIfNeeded() async {
        guard metadata == nil, !isLoading else { return }

        isLoading = true
        let result = await useCase.execute()
        isLoading = false

        switch result {
        case .success(let data):
            self.metadata = data
        case .failure(let error):
            self.error = error
            print("Failed to load metadata: \(error)")
        }
    }

    // 특정 시군구의 shelter만 로드 (지연 로딩)
    private func loadSheltersIfNeeded(sido: String, sigungu: SigunguEntity) async {
        // 이미 캐시에 있으면 스킵
        guard shelterCache[sigungu] == nil else { return }

        isLoadingShelters = true
        let result = await useCase.fetchSheltersForSigungu(sido: sido, sigungu: sigungu.id)
        isLoadingShelters = false

        if case .success(let shelters) = result {
            shelterCache[sigungu] = shelters
        }
    }

    // 현재 시군구의 shelter 반환
    func getSheltersForCurrentSigungu() -> [ShelterEntity] {
        guard let sigungu = sigungu else { return [] }
        return shelterCache[sigungu] ?? []
    }

    func reset() {
        beginDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        endDate = Date()
        upkind = nil
        kinds.removeAll()
        sido = nil
        sigungu = nil
        shelter = nil
        state = .notice
        neutral = nil
    }

    func didTapSearchButton() {
        onSearchCompleted?(makeFilters())
    }

    private func makeFilters() -> [AnimalSearchFilter] {
        var result: [AnimalSearchFilter] = []
        for kind in kinds {
            let aFilter = AnimalSearchFilter(
                beginDate: beginDate,
                endDate: endDate,
                upkind: upkind?.id,
                kind: kind.id,
                sido: sido?.id,
                sigungu: sigungu?.id,
                shelterNumber: shelter?.id,
                processState: state.id,
                neutralizationState: neutral?.id
            )
            result.append(aFilter)
        }
        return result
    }
}
