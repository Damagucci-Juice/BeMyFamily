//
//  AnimalFilterForm.swift
//  BeMyFamily
//
//  Created by Gucci on 4/13/24.
//

import SwiftUI

struct AnimalFilterForm: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var reducer: FeedViewModel
    @EnvironmentObject var filterReducer: FilterViewModel
    @EnvironmentObject var provinceReducer: ProvinceViewModel

    var body: some View {
        NavigationStack {
            Form {
                Button {
                    reducer.setMenu(.feed)
                    filterReducer.reset()
                    Task {
                        let sleepTimeNanoSec: UInt64 = 500 * 1_000_000
                        try? await Task.sleep(nanoseconds: sleepTimeNanoSec)

                        await MainActor.run { dismiss() }
                    }
                } label: {
                    Label {
                        Text("필터 초기화")
                    } icon: {
                        Image(systemName: UIConstants.Image.reset)
                    }
                }

                Section(header: Text("검색 일자")) {
                    DatePicker("시작일", selection: $filterReducer.beginDate,
                               in: ...filterReducer.endDate.addingTimeInterval(UIConstants.Date.aDayBefore),
                               displayedComponents: .date)
                    DatePicker("종료일", selection: $filterReducer.endDate,
                               in: ...Date(),
                               displayedComponents: .date)
                }

                Section("지역을 골라주세요") {
                    Picker("시도", selection: $filterReducer.sido) {
                        Text(UIConstants.FilterForm.showAll)
                            .tag(nil as SidoDTO?)

                        ForEach(provinceReducer.sido, id: \.self) { eachSido in
                            Text(eachSido.name)
                                .tag(eachSido as SidoDTO?)
                        }
                    }
                    .onChange(of: filterReducer.sido) { _, _ in
                        filterReducer.sigungu = nil
                    }

                    if let sido = filterReducer.sido {
                        Picker("시군구", selection: $filterReducer.sigungu) {
                            let sigungus = provinceReducer.province[sido, default: []]
                            Text(UIConstants.FilterForm.showAll)
                                .tag(nil as SigunguDTO?)

                            ForEach(sigungus, id: \.self) { eachSigungu in
                                if let sigunguName = eachSigungu.name {
                                    Text(sigunguName)
                                        .tag(eachSigungu as SigunguDTO?)
                                }
                            }
                        }
                        .onChange(of: filterReducer.sigungu) { _, _ in
                            filterReducer.shelter = nil
                        }
                    }
                }

                if filterReducer.sido != nil, let sigungu = filterReducer.sigungu {
                    Section("보호소를 선택하세요.") {
                        Picker("보호소", selection: $filterReducer.shelter) {
                            Text(UIConstants.FilterForm.showAll)
                                .tag(nil as ShelterDTO?)

                            let shelter = provinceReducer.shelter[sigungu, default: []]
                            ForEach(shelter, id: \.self) { eachShelter in
                                Text(eachShelter.name)
                                    .tag(eachShelter as ShelterDTO?)
                            }
                        }
                    }
                }

                Section("현재 어떤 상태인가요?") {
                    Picker("처리 상태", selection: $filterReducer.state) {
                        ForEach(ProcessState.allCases, id: \.self) { process in
                            Text(process.text)
                        }
                    }
                }

                Section("중성화 여부") {
                    Picker("중성화 여부", selection: $filterReducer.neutral) {
                        Text(UIConstants.FilterForm.showAll)
                            .tag(nil as Neutralization?)

                        ForEach(Neutralization.allCases, id: \.self) { neutralization in
                            Text(neutralization.text)
                                .tag(neutralization as Neutralization?)
                        }
                    }
                }

                kindSection
            }
            .navigationTitle(UIConstants.FilterForm.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        reducer.setMenu(.filter)
                        Task {
                            await fetchAnimalsWithFilter()
                        }
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

extension AnimalFilterForm {

    @ViewBuilder
    private var kindSection: some View {
        Section(header: Text("어떤 종을 보고 싶으신가요?")) {
            // 상위 카테고리 (강아지, 고양이 등)
            Picker("축종", selection: $filterReducer.upkind) {
                Text(UIConstants.FilterForm.showAll).tag(nil as Upkind?)
                ForEach(Upkind.allCases, id: \.self) { upkind in
                    Text(upkind.text).tag(upkind as Upkind?)
                }
            }
            .onChange(of: filterReducer.upkind) { _, _ in
                filterReducer.kinds.removeAll()
            }

            // 품종 리스트 - List 대신 ForEach를 사용하여 Section에 직접 배치
            if let upkind = filterReducer.upkind, let kinds = provinceReducer.kind[upkind] {
                // 품종이 너무 많을 경우를 대비해 검색 버튼이나 내비게이션 링크로 빼는 것이 좋지만,
                // 일단 화면에 바로 노출하려면 ForEach를 씁니다.
                ForEach(kinds, id: \.id) { kind in
                    let isSelected = filterReducer.kinds.contains(kind)

                    Button {
                        if isSelected {
                            filterReducer.kinds.remove(kind)
                        } else {
                            filterReducer.kinds.insert(kind)
                        }
                    } label: {
                        togglingCheckbox(kind, isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func togglingCheckbox(_ kind: KindDTO, _ isSelected: Bool) -> some View {
        let image = isSelected ? "checkmark.circle.fill" : "circle"
        HStack {
            Image(systemName: image)
                .foregroundStyle(isSelected ? .blue : .gray)
            Text(kind.name)
        }
    }
}

extension AnimalFilterForm {
    func fetchAnimalsWithFilter() async {
        let filters = filterReducer.makeFilter()
        await reducer.fetchAnimalsIfCan(filters)
    }
}

#Preview {
    @StateObject var filterReducer = DIContainer.makeFilterViewModel()

    return NavigationStack {
        AnimalFilterForm()
            .environmentObject(filterReducer)
            .environmentObject(DIContainer.makeFeedListViewModel(filterReducer))
            .environmentObject(DIContainer.makeProvinceViewModel())
    }
}
