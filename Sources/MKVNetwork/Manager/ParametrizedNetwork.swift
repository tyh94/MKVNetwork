//
//  ParametrizedNetwork.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 17.07.2025.
//

import Foundation

extension NetworkManaging {
    public func parametrized(with parameters: Request.Parameters) -> NetworkManaging {
        ParametrizedNetwork(loader: self, parameters: parameters)
    }
}

final class ParametrizedNetwork: NetworkManaging {
    private let loader: NetworkManaging
    private let storedParameters: Request.Parameters
    
    public init(
        loader: NetworkManaging,
        parameters: Request.Parameters
    ) {
        self.loader = loader
        self.storedParameters = parameters
    }
    
    func dataRequest<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil,
        decoder: JSONDecoder? = nil
    ) async throws -> T {
        try await loader.dataRequest(
            url: url,
            method: method,
            headers: headers,
            parameters: storedParameters + parameters,
            decoder: decoder
        )
    }

    @discardableResult
    func dataRequest(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil,
    ) async throws -> Data {
        try await loader.dataRequest(
            url: url,
            method: method,
            headers: headers,
            parameters: storedParameters + parameters
        )
    }
    
    func uploadRequest<T: Decodable>(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?,
        decoder: JSONDecoder?
    ) async throws -> T {
        try await loader.uploadRequest(
            data: data,
            url: url,
            method: method,
            headers: headers ,
            parameters: storedParameters + parameters,
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
        try await loader.uploadRequest(
            data: data,
            url: url,
            method: method,
            headers: headers ,
            parameters: storedParameters + parameters
        )
    }
}

