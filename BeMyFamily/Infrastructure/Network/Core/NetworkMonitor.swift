//
//  NetworkMonitor.swift
//  BeMyFamily
//
//  Created by Gucci on 12/25/25.
//

import Network
import Combine
import Observation

// Data 계층의 구현체
final class NetworkMonitor: NetworkMonitoring {
    // @Published를 써야 SwiftUI가 변화를 감지함
    @Published var isConnected: Bool = false

    private let monitor = NWPathMonitor()

    static let shared = NetworkMonitor()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue.global())
    }
}
