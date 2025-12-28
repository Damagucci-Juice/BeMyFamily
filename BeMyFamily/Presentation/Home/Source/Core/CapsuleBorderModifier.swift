//
//  CapsuleBorderModifier.swift
//  BeMyFamily
//
//  Created by Gucci on 12/27/25.
//


import SwiftUI

struct CapsuleBorderModifier: ViewModifier {
    var borderColor: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(.clear)
            }
            .overlay {
                Capsule()
                    .stroke(borderColor, lineWidth: 0.8)
            }
    }
}
