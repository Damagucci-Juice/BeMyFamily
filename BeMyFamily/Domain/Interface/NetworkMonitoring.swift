//
//  NetworkMonitoring.swift
//  BeMyFamily
//
//  Created by Gucci on 12/25/25.
//
import Combine

protocol NetworkMonitoring: ObservableObject {
    var isConnected: Bool { get }
}
