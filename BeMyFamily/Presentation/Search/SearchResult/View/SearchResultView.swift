//
//  SearchResultView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//

import SwiftUI

struct SearchResultView: View {
    @Environment(Coordinator.self) var coordinator
    @Bindable var viewModel: SearchResultViewModel

    init(viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text("SearchResultView")
    }
}
