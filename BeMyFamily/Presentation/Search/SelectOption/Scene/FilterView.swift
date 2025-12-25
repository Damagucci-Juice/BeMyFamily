//
//  FilterView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/13/24.
//
//

import SwiftUI

struct FilterView: View {
    @Bindable var viewModel: FilterViewModel
    @State private var searchViewModel = DIContainer.shared.resolveFactory(SearchResultViewModel.self)
    @State private var isSearchActive = false
    @State private var isKindSearchActive = false

    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                // 로딩 중 UI
                VStack(spacing: 16) {
                    ProgressView()
                    Text("필터 정보를 불러오는 중...")
                        .foregroundStyle(.secondary)
                }
            } else {
                optionSelectionContentView
            }
        }
        .navigationTitle(UIConstants.FilterForm.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 검색 버튼
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    searchButtonDidTapped()
                } label: {
                    Text("검색")
                }
                .disabled(viewModel.isLoading)
            }

            // 초기화 버튼
            ToolbarItem(placement: .cancellationAction) {
                resetButton()
            }
        }
        .navigationDestination(isPresented: $isSearchActive) {
            if let searchViewModel {
                SearchResultView(viewModel: searchViewModel)
            }
        }
        .navigationDestination(isPresented: $isKindSearchActive) {
            if !viewModel.isLoading {
                KindSearchView(selectedKinds: $viewModel.kinds, allKinds: viewModel.allKinds())
            }
        }
        .onAppear {
            if searchViewModel?.animals.isEmpty == false {
                searchViewModel?.clearAll()
            }

        }
    }

    @ViewBuilder
    private var optionSelectionContentView: some View {
        List {
            Section {
                kindSelectionButton
                    .listRowSeparator(.hidden)
            }

            if !viewModel.kinds.isEmpty {
                VStack {
                    selectedChipKinds
                }
                .background(.clear)
                .listRowSeparator(.hidden)
            }

            Section(header: Text("검색 일자")) {
                DatePicker("시작일", selection: $viewModel.beginDate,
                           in: ...viewModel.endDate.addingTimeInterval(-86400),
                           displayedComponents: .date)
                DatePicker("종료일", selection: $viewModel.endDate,
                           in: ...Date(),
                           displayedComponents: .date)
            }
            .listRowSeparator(.hidden)

            Section("지역을 골라주세요") {
                Picker("시도", selection: $viewModel.sido) {
                    Text(UIConstants.FilterForm.showAll)
                        .tag(nil as SidoEntity?)
                    ForEach(viewModel.sidos(), id: \.self) { aSido in
                        Text(aSido.name)
                            .tag(aSido as SidoEntity?)
                    }
                }
                .onChange(of: viewModel.sido) { _, _ in
                    viewModel.sigungu = nil
                }

                if viewModel.sido != nil {
                    Picker("시군구", selection: $viewModel.sigungu) {
                        Text(UIConstants.FilterForm.showAll)
                            .tag(nil as SigunguEntity?)

                        ForEach(viewModel.sigungus(), id: \.self) { eachSigungu in
                            if let sigunguName = eachSigungu.name {
                                Text(sigunguName)
                                    .tag(eachSigungu as SigunguEntity?)
                            }
                        }
                    }
                    .onChange(of: viewModel.sigungu) { _, _ in
                        viewModel.shelter = nil
                    }
                }
            }
            .listRowSeparator(.hidden)

            if viewModel.sigungu != nil {
                Section("보호소를 선택하세요.") {
                    if viewModel.isLoadingShelters {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 8)
                            Text("보호소 목록 불러오는 중...")
                        }
                    } else {
                        Picker("보호소", selection: $viewModel.shelter) {
                            Text(UIConstants.FilterForm.showAll)
                                .tag(nil as ShelterEntity?)

                            let shelters = viewModel.getSheltersForCurrentSigungu()
                            ForEach(shelters, id: \.self) { eachShelter in
                                Text(eachShelter.name)
                                    .tag(eachShelter as ShelterEntity?)
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }

            Section("현재 어떤 상태인가요?") {
                Picker("처리 상태", selection: $viewModel.state) {
                    ForEach(ProcessState.allCases, id: \.self) { process in
                        Text(process.text)
                    }
                }
            }
            .listRowSeparator(.hidden)

            Section("중성화 여부") {
                Picker("중성화 여부", selection: $viewModel.neutral) {
                    Text(UIConstants.FilterForm.showAll)
                        .tag(nil as Neutralization?)

                    ForEach(Neutralization.allCases, id: \.self) { neutralization in
                        Text(neutralization.text)
                            .tag(neutralization as Neutralization?)
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var kindSelectionButton: some View {
        Button {
            isKindSearchActive.toggle()
        } label: {
            HStack {
                Text("어떤 품종을 보고 싶으신가요?")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

    }

    @ViewBuilder
    private var selectedChipKinds: some View {
        ZStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Array(viewModel.kinds)) { kind in
                        KindChipView(kind: kind, isSelected: true, action: {
                            viewModel.toggleKind(kind)
                        })
                    }
                }
            }
            .scrollIndicators(.never)

            HStack {
                Spacer()

                Button {
                    viewModel.clearKinds()
                } label: {
                    Text("X")
                        .foregroundStyle(.gray.opacity(0.85))
                }
                .buttonStyle(.glass) // 커스텀 스타일 대신 기본 스타일 사용 시
            }
        }
    }

    @ViewBuilder
    private func togglingCheckbox(_ kind: KindEntity, _ isSelected: Bool) -> some View {
        let image = isSelected ? "checkmark.circle.fill" : "circle"
        HStack {
            Image(systemName: image)
                .foregroundStyle(isSelected ? .blue : .gray)
            Text(kind.name)
        }
    }

    @ViewBuilder
    private func resetButton() -> some View {
        Button {
            viewModel.reset()
        } label: {
            Label {
                Text("필터 초기화")
            } icon: {
                Image(systemName: UIConstants.Image.reset)
            }
        }
    }

    private func searchButtonDidTapped() {
        guard let searchViewModel else { return }
        let filters = viewModel.makeFilters()
        searchViewModel.setupFilters(filters)
        isSearchActive.toggle()
    }
}
