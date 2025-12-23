//
//  ContentView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/9/24.
//
import Combine
import SwiftUI

struct ContentView: View {
    @Environment(DIContainer.self) private var diContainer

    var body: some View {
        if let coordi = diContainer.resolveSingleton(Coordinator.self) {
            TabControlView(coordinator: coordi)
        }
    }
}

#Preview {
    ContentView()
}
