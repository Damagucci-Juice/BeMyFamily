//
//  KindChipView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/25/25.
//
import SwiftUI

struct KindChipView: View {
    let kind: KindEntity
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            Text(kind.name)
                .font(.system(size: 13, weight: isSelected ? .bold : .light))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity) // 그리드 칸을 꽉 채우는 핵심
                .background(backgroundView)
                .foregroundColor(isSelected ? .white : .primary)
                .shadow(color: isSelected ? Color.blue.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // 배경 로직을 변수로 분리하여 가독성 향상
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? (colorScheme == .dark ? Color.blue : Color.black) : Color(.systemGray6))
    }
}
