//
//  NetworkRepository.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//

import Foundation
import Combine

protocol NetworkRepository {
    func observeNetworkStatus() -> AnyPublisher<NetworkStatus, Never>
}
