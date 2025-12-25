//
//  UpkindChipView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/25/25.
//
import SwiftUI

struct UpkindChipView: View {
    let kind: Upkind
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            Text(kind.text)
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundStyle(isSelected ? (colorScheme == .dark ? .white : .black) : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
        }
        .buttonStyle(.glass) // 기존에 정의하신 glass 스타일 사용
    }
}
