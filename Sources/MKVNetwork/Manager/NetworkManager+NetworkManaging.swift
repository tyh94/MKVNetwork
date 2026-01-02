//
//  DataLoader.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 16.03.2025.
//

import Foundation

extension NetworkManager: NetworkManaging {
    public func dataRequest<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?,
        decoder: JSONDecoder?
    ) async throws -> T {
        let data = try await dataRequest(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters
        )
        
        let decoder = decoder ?? JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    @discardableResult
    public func dataRequest(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?
    ) async throws -> Data {
        let request = try Request(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            timeoutInterval: timeoutInterval
        )
        
        let (data, response) = try await session.data(for: request.urlRequest)
        return try handle(response: response, content: data)
    }
    
    public func uploadRequest(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?
    ) async throws -> Data {
        let request = try Request(
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            timeoutInterval: timeoutInterval
        )
        
        let (data, response) = try await session.upload(for: request.urlRequest, from: data)
        return try handle(response: response, content: data)
    }
    
    public func uploadRequest<T: Decodable>(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?,
        decoder: JSONDecoder?
    ) async throws -> T {
        let data = try await uploadRequest(
            data: data,
            url: url,
            method: method,
            headers: headers,
            parameters: parameters
        )
        
        let decoder = decoder ?? JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
