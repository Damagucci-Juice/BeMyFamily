//
//  KindSearchView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/24/25.
//
import SwiftUI

struct KindSearchView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss

    @Binding var selectedKinds: Set<KindEntity>
    let allKinds: [Upkind: [KindEntity]]

    @State private var searchText: String = ""
    @State private var upkind: Upkind? = .dog
    @FocusState private var isKeyboardFocused: Bool

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    // MARK: - Computed Properties
    private var filteredKinds: [KindEntity] {
        let baseKinds = upkind.flatMap { allKinds[$0] } ?? allKinds.values.flatMap { $0 }

        return baseKinds.filter { kind in
            let isNotSelected = !selectedKinds.contains(kind)
            let matchesSearch = isKeyboardFocused && !searchText.isEmpty
            ? (kind.name.contains(searchText) || kind.id.contains(searchText))
            : true
            return isNotSelected && matchesSearch
        }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            searchBar

            ZStack {
                mainContentArea

                VStack {
                    filterCategoryBar

                    Spacer()

                    if !selectedKinds.isEmpty {
                        selectionSummaryBar
                    }
                }
            }
        }
        .navigationTitle("품종 고르기")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isKeyboardFocused) { _, focused in
            withAnimation(.snappy) { upkind = focused ? nil : .dog }
        }
    }
}

// MARK: - Subviews
private extension KindSearchView {

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("차우차우, 골든 리트리버", text: $searchText)
                .focused($isKeyboardFocused)
                .font(.system(size: 15))
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }

    var filterCategoryBar: some View {
        HStack {
            ForEach(Upkind.allCases, id: \.self) { kind in
                UpkindChipView(kind: kind, isSelected: self.upkind == kind) {
                    self.upkind = (self.upkind == kind) ? nil : kind
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    var mainContentArea: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredKinds) { kind in
                    KindChipView(kind: kind, isSelected: false) {
                        toggleSelection(kind)
                    }
                }
            }
            .padding(.top, 60)
        }
        .scrollIndicators(.never)
    }

    var selectionSummaryBar: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Array(selectedKinds)) { kind in
                        SelectedKindTag(kind: kind) {
                            selectedKinds.remove(kind)
                        }
                    }
                }
                .padding(.horizontal)
            }

            completeButton
        }
    }

    var completeButton: some View {
        Button { dismiss() } label: {
            Text("선택 완료 (\(selectedKinds.count))")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.glass)
        .padding(.horizontal)
    }

    func toggleSelection(_ kind: KindEntity) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedKinds.contains(kind) {
                selectedKinds.remove(kind)
            } else {
                selectedKinds.insert(kind)
            }
        }
    }
}

// MARK: - Helper Views
struct SelectedKindTag: View {
    let kind: KindEntity
    let onRemove: () -> Void

    var body: some View {
        Button(action: onRemove) {
            Text(kind.name).font(.caption).bold()
        }
        .buttonStyle(.glass)
    }
}
