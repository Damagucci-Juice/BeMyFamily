//
//  BeMyFamilyApp.swift
//  BeMyFamily
//
//  Created by Gucci on 4/9/24.
//

import SwiftUI

@main
struct BeMyFamilyApp: App {
    @State private var deepLinkManager = DeepLinkManager()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(deepLinkManager) // 하위 뷰에서 접근 가능하게 주입
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    handleUnivalsialLink(url)
                }
        }
    }
    
    private func handleUnivalsialLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return }
        
        if let desertionNo = queryItems.first(where: { $0.name == "id" })?.value {
            // 매니저에 ID 저장 -> 하위 뷰에서 감지하여 시트를 띄움
            self.deepLinkManager.selectedDesertionNo = desertionNo
            print("Universal Link 수신 ID: \(desertionNo)")
        }
    }
}

