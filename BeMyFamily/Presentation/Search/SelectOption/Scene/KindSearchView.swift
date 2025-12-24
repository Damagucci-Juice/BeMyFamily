//
//  KindSearchView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/24/25.
//
import SwiftUI

struct KindSearchView: View {
    let allKinds: [Upkind: [KindEntity]]
    @State private var searchText: String = ""
    @Binding var selectedKinds: Set<KindEntity>
    @State private var upkind: Upkind? = Upkind.dog

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var filteredKinds: [KindEntity] {
        let baseKinds: [KindEntity]

        if let upkind {
            // 특정 카테고리가 선택된 경우 해당 카테고리만 대상으로 함
            baseKinds = allKinds[upkind, default: []]
        } else {
            // 카테고리가 없는 경우 전체를 대상으로 함
            baseKinds = allKinds.values.flatMap { $0 }
        }

        // 검색어가 비어있다면 필터링 없이 반환합니다.
        guard !searchText.isEmpty else {
            return baseKinds
        }

        // 검색어가 있다면 대상 범위(baseKinds) 내에서 필터링합니다.
        return baseKinds.filter { kind in
            kind.name.contains(searchText) || kind.id.contains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 20) {
                // 축종 선택
                HStack {
                    ForEach(Upkind.allCases, id: \.self) {
                        upkindChipView($0)
                    }
                }

                // 헤더 및 검색바 영역 (고정)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("코드 또는 이름 검색", text: $searchText)
                        .font(.system(size: 15))
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)

            }
            .padding(.horizontal)
            .padding(.bottom, 16)

            // 2. 수직 그리드 영역 (스크롤 가능)
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
                .padding(.top, 8)
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
}

struct UpkindChipView: View {
    let kind: Upkind
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(kind.text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? (colorScheme == .dark ? Color.black : Color.white) : .white)
                    .lineLimit(1) // 한 줄로 제한
                    .minimumScaleFactor(0.8) // 글자가 길면 자동 축소

                Text(kind.id)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(isSelected ? (colorScheme == .dark ? Color.black : Color.white) : .white)
                    .opacity(0.6)
            }
            .frame(maxWidth: .infinity) // 3열 그리드 칸을 꽉 채움
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? (colorScheme == .dark ? Color.white : Color.black) : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : .primary)
            // 선택 시 살짝 떠오르는 듯한 효과
            .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct KindChipView: View {
    let kind: KindEntity
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(kind.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1) // 한 줄로 제한
                    .minimumScaleFactor(0.8) // 글자가 길면 자동 축소

                Text(kind.id)
                    .font(.system(size: 10, design: .monospaced))
                    .opacity(0.6)
            }
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
