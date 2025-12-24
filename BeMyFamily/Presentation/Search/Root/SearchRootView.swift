//
//  SearchRootView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//

import SwiftUI

@Observable
final class SearchRouter {
    var path = NavigationPath()
}

struct SearchRootView: View {
    @Bindable var router: SearchRouter
    @Environment(DIContainer.self) var diContainer


    var body: some View {
        NavigationStack {
            if let viewModel = diContainer.resolveFactory(FilterViewModel.self) {
                FilterView(viewModel: viewModel)
            }
        }
    }
}
