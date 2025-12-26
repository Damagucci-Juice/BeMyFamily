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
            VStack(spacing: 4) {
                Image(kind.image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 150)
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))

                Text(kind.limittedName)
                    .font(.system(size: 16, weight: isSelected ? .bold : .bold))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    // 배경 로직을 변수로 분리하여 가독성 향상
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? (colorScheme == .dark ? Color.blue : Color.black) : Color(.systemGray6))
    }
}

#Preview {
    KindChipView(kind: .init(id: "35",
                             name: "차우차우",
                             upKind: .dog),
                 isSelected: false,
                 action: {})
}
