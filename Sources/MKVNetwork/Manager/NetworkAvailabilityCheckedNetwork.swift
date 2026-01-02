//
//  NetworkAvailabilityCheckedNetwork.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 28.10.2025.
//

import Foundation

extension NetworkManaging {
    public func withNetworkAvailabilityCheck() -> NetworkManaging {
        NetworkAvailabilityCheckedNetwork(loader: self)
    }
}

final class NetworkAvailabilityCheckedNetwork: NetworkManaging {
    private let loader: NetworkManaging
    private let networkChecker: NetworkAvailabilityChecking
    
    public init(
        loader: NetworkManaging,
        networkChecker: NetworkAvailabilityChecking = DefaultNetworkAvailabilityChecker()
    ) {
        self.loader = loader
        self.networkChecker = networkChecker
    }
    
    func dataRequest<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil,
        decoder: JSONDecoder? = nil
    ) async throws -> T {
        try await checkNetworkAvailability()
        return try await loader.dataRequest(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            decoder: decoder
        )
    }

    @discardableResult
    func dataRequest(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil
    ) async throws -> Data {
        try await checkNetworkAvailability()
        return try await loader.dataRequest(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters
        )
    }
    
    func uploadRequest<T: Decodable>(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil,
        decoder: JSONDecoder? = nil
    ) async throws -> T {
        try await checkNetworkAvailability()
        return try await loader.uploadRequest(
            data: data,
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            decoder: decoder
        )
    }
    
    func uploadRequest(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil
    ) async throws -> Data {
        try await checkNetworkAvailability()
        return try await loader.uploadRequest(
            data: data,
            url: url,
            method: method,
            headers: headers,
            parameters: parameters
        )
    }
    
    private func checkNetworkAvailability() async throws {
        guard await networkChecker.isNetworkAvailable() else {
            throw NetworkError.noInternetConnection
        }
    }
}
