//
//  NetworkAvailabilityChecking.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 28.10.2025.
//

import Foundation

public protocol NetworkAvailabilityChecking: Sendable {
    func isNetworkAvailable() async -> Bool
}
