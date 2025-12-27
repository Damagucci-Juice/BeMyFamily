//
//  View+extension.swift
//  BeMyFamily
//
//  Created by Gucci on 12/27/25.
//
import SwiftUI

extension View {
    func capsuleBorder(color: Color = .secondary.opacity(0.4)) -> some View {
        self.modifier(CapsuleBorderModifier(borderColor: color))
    }
}
