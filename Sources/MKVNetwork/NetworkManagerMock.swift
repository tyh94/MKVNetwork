//
//  NetworkManagerMock.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 17.07.2025.
//

import Foundation

public final class NetworkManagerMock: NetworkManaging {
    public init() {}
    
    public func dataRequest<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?,
        decoder: JSONDecoder?
    ) async throws -> T {
        throw ""
    }

    public func dataRequest(    
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?
    ) async throws -> Data {
        Data()
    }
    
    public func uploadRequest<T: Decodable>(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?,
        decoder: JSONDecoder?
    ) async throws -> T {
        throw ""
    }

    public func uploadRequest(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?
    ) async throws -> Data {
        Data()
    }
}
