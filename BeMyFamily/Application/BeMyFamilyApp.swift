//
//  BeMyFamilyApp.swift
//  BeMyFamily
//
//  Created by Gucci on 4/9/24.
//

import SwiftUI

@main
struct BeMyFamilyApp: App {
    @StateObject private var diContainer = DIContainer(dependencies: .init(apiService: FamilyService()))
    @StateObject private var filterReducer: FilterViewModel
    @StateObject private var reducer: FeedViewModel
    @StateObject private var provinceReducer: ProvinceViewModel

    init() {
        let filterReducer = DIContainer.makeFilterViewModel()
        _filterReducer = StateObject(wrappedValue: filterReducer)
        _reducer = StateObject(wrappedValue: DIContainer.makeFeedListViewModel(filterReducer))
        _provinceReducer = StateObject(wrappedValue: DIContainer.makeProvinceViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diContainer)
                .environmentObject(filterReducer)
                .environmentObject(provinceReducer)
                .environmentObject(reducer)
                .preferredColorScheme(.dark)
        }
    }
}
