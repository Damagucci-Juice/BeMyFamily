//
//  MinimalTestView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//


import SwiftUI

// 가장 단순한 형태로 테스트
struct MinimalTestView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text("메인 화면")
                
                Button("필터로 이동") {
                    print("🔘 버튼 클릭, path count: \(path.count)")
                    path.append(SearchFlow.filter)
                    print("🔘 추가 후 path count: \(path.count)")
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationDestination(for: SearchFlow.self) { flow in
                switch flow {
                case .filter:
                    Text("필터 화면")
                        .navigationTitle("필터")
                case .searchResult:
                    Text("검색 결과")
                        .navigationTitle("결과")
                }
            }
        }
    }
}

// 이것도 테스트
struct SimpleCoordinatorTest: View {
    @State private var coordinator = SimpleCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack {
                Text("메인")
                Button("이동") {
                    coordinator.push(.filter)
                }
            }
            .navigationDestination(for: SearchFlow.self) { flow in
                Text("목적지: \(String(describing: flow))")
            }
        }
    }
}

@Observable
class SimpleCoordinator {
    var path = NavigationPath()
    
    func push(_ page: SearchFlow) {
        print("🚀 push: \(page), before: \(path.count)")
        path.append(page)
        print("🚀 after: \(path.count)")
    }
}

#Preview("Minimal") {
    MinimalTestView()
}

#Preview("Coordinator") {
    SimpleCoordinatorTest()
}
