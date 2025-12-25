//
//  KindSearchView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/24/25.
//
import SwiftUI

struct KindSearchView: View {

    @State private var searchText: String = ""
    @FocusState private var isKeyboardFocused
    @Binding var selectedKinds: Set<KindEntity>
    @State private var upkind: Upkind? = Upkind.dog
    @Environment(\.dismiss) var dismiss

    let allKinds: [Upkind: [KindEntity]]
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var showCompleteButton: Bool { !selectedKinds.isEmpty }
    private var filteredKinds: [KindEntity] {
        // 1. 기본 대상(Base) 결정
        let baseKinds = upkind.flatMap { allKinds[$0] } ?? allKinds.values.flatMap { $0 }

        // 2. 필터링 로직 통합
        return baseKinds.filter { kind in
            // 이미 선택된 항목은 무조건 제외
            guard !selectedKinds.contains(kind) else { return false }

            // 키보드 포커스 상태이고 검색어가 있다면 검색 조건 추가
            if isKeyboardFocused && !searchText.isEmpty {
                return kind.name.contains(searchText) || kind.id.contains(searchText)
            }

            // 그 외 상황(검색어 없음 또는 포커스 아님)은 모두 포함
            return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더 및 검색바 영역 (고정)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("차우차우, 골든 리트리버", text: $searchText)
                    .focused($isKeyboardFocused)
                    .font(.system(size: 15))
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            // 2. 수직 그리드 영역 (스크롤 가능)
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredKinds) { kind in
                            KindChipView(
                                kind: kind,
                                isSelected: selectedKinds.contains(kind)
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    toggleSelection(kind)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 32)
                }
                .scrollIndicators(.never)

                VStack {
                    // 축종 선택 뷰
                    HStack {
                        ForEach(Upkind.allCases, id: \.self) {
                            upkindChipView($0)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .onChange(of: isKeyboardFocused) { _, newValue in
                        if newValue {
                            upkind = nil
                        } else {
                            upkind = .dog
                        }
                    }

                    Spacer()

                    // 선택된 품종 뷰
                    ScrollView(.horizontal) {
                        HStack {
                            if !selectedKinds.isEmpty {
                                ForEach(Array(selectedKinds)) { kind in
                                    KindChipView(kind: kind, isSelected: selectedKinds.contains(kind), action: {
                                        if selectedKinds.contains(kind) {
                                            selectedKinds.remove(kind)
                                        }
                                    })
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .scrollIndicators(.never)

                    // 완료 버튼
                    if showCompleteButton {
                        completeButton()
                            .padding(.bottom)
                    }
                }
            }

            // 하단 상태 표시
            Text("\(filteredKinds.count)개의 품종 검색됨")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
        }
        .background(Color(.systemBackground)) // 배경색 설정
        .navigationTitle("품종 고르기")
    }

    private func toggleSelection(_ kind: KindEntity) {
        if selectedKinds.contains(kind) {
            selectedKinds.remove(kind)
        } else {
            selectedKinds.insert(kind)
        }
    }

    @ViewBuilder
    private func upkindChipView(_ upkind: Upkind) -> some View {
        UpkindChipView(kind: upkind, isSelected: self.upkind == upkind) {
            if self.upkind == upkind {
                self.upkind = nil
            } else {
                self.upkind = upkind
            }
        }
    }

    @ViewBuilder
    private func completeButton() -> some View {
        Button {
            dismiss()
        } label: {
            Text("완료")
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding(8)
        }
        .buttonStyle(.glass)
        .padding(.horizontal)
    }
}

struct UpkindChipView: View {
    let kind: Upkind
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    private var font: Font {
        isSelected ? .system(size: 16, weight: .bold) : .system(size: 16, weight: .regular)
    }
    private var color: Color {
        isSelected ? (colorScheme == .dark ? Color.white : Color.black) : .gray
    }

    var body: some View {
        Button(action: action) {
            Text(kind.text)
                .font(font)
                .foregroundStyle(color)
        }
        .buttonStyle(.glass)
    }
}

struct KindChipView: View {
    let kind: KindEntity
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme
    private var font: Font {
        isSelected ? .system(size: 13, weight: .bold) : .system(size: 13, weight: .light)
    }

    var body: some View {
        Button(action: action) {
            Text(kind.name)
                .font(font)
                .lineLimit(1) // 한 줄로 제한
                .minimumScaleFactor(0.8) // 글자가 길면 자동 축소
                .frame(maxWidth: .infinity) // 3열 그리드 칸을 꽉 채움
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? (colorScheme == .dark ? Color.blue : Color.black) : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
            // 선택 시 살짝 떠오르는 듯한 효과
                .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
