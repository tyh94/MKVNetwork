//
//  Request.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 16.03.2025.
//

import Foundation

public final class Request: @unchecked Sendable {
    private(set) var urlRequest: URLRequest

    init(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Parameters?,
        timeoutInterval: TimeInterval
    ) throws {
        urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers.reduce(into: [:]) { $0[$1.name] = $1.value }
        urlRequest.timeoutInterval = timeoutInterval
        
        if let parameters {
            switch parameters.destination {
            case .query:
                guard let (query, encoding) = parameters.object as? (Query<String>, QueryEncoding) else {
                    throw "Cannot resolve query object"
                }
                
                urlRequest.url = query.encode(to: url, encoding: encoding)
            case .body:
                guard let data = parameters.object as? Data else {
                    throw "Cannot resolve data object"
                }
                
                urlRequest.httpBody = data
            }
        }
    }
}
