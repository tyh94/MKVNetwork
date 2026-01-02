//
//  DefaultNetworkAvailabilityChecker.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 29.10.2025.
//

import Foundation
import Network

public actor DefaultNetworkAvailabilityChecker: NetworkAvailabilityChecking {
    private let queue = DispatchQueue(label: "NetworkAvailabilityCheckerQueue")

    public init() {}

    public func isNetworkAvailable() async -> Bool {
        let status = await currentPathStatus()
        if status == .satisfied {
            return await hasInternetAccess()
        } else {
            return false
        }
    }

    private func currentPathStatus() async -> NWPath.Status {
        await withCheckedContinuation { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                continuation.resume(returning: path.status)
                monitor.cancel()
            }

            monitor.start(queue: queue)
        }
    }

    private func hasInternetAccess() async -> Bool {
        guard let url = URL(string: "https://www.apple.com/library/test/success.html") else { return false }
        var request = URLRequest(url: url)
        request.timeoutInterval = 3

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return (200..<300).contains(httpResponse.statusCode)
            }
            return false
        } catch {
            return false
        }
    }
}
