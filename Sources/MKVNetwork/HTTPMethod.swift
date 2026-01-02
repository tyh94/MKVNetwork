//
//  HTTPMethod.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 16.03.2025.
//

import Foundation

public struct HTTPMethod: RawRepresentable, Equatable, Hashable, Sendable, Codable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension HTTPMethod {
    static let connect = HTTPMethod(rawValue: "CONNECT")
    static let delete = HTTPMethod(rawValue: "DELETE")
    static let get = HTTPMethod(rawValue: "GET")
    static let head = HTTPMethod(rawValue: "HEAD")
    static let options = HTTPMethod(rawValue: "OPTIONS")
    static let patch = HTTPMethod(rawValue: "PATCH")
    static let post = HTTPMethod(rawValue: "POST")
    static let put = HTTPMethod(rawValue: "PUT")
    static let trace = HTTPMethod(rawValue: "TRACE")
}
