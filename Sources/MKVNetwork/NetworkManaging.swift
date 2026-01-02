//
//  NetworkManaging.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 17.07.2025.
//

import Foundation

public protocol NetworkManaging: AnyObject, Sendable {
    func dataRequest<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?,
        decoder: JSONDecoder?
    ) async throws -> T
    
    func dataRequest(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?
    ) async throws -> Data
    
    func uploadRequest<T: Decodable>(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?,
        decoder: JSONDecoder?
    ) async throws -> T
    
    func uploadRequest(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?
    ) async throws -> Data
}

public extension NetworkManaging {
    func dataRequest<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil,
        decoder: JSONDecoder? = nil
    ) async throws -> T {
        try await dataRequest(
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
        try await dataRequest(
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
        try await uploadRequest(
            data: data,
            url: url,
            method: method,
            headers: headers,
            parameters: parameters,
            decoder: decoder
        )
    }

    @discardableResult
    func uploadRequest(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil
    ) async throws -> Data {
        try await uploadRequest(
            data: data,
            url: url,
            method: method,
            headers: headers,
            parameters: parameters
        )
    }
}
