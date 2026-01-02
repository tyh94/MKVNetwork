//
//  Request.Error.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 16.03.2025.
//

import Foundation

extension Request {
    public struct Error: LocalizedError, Codable {
        public var code: Int
        public var error: String?
        
        public var statusCode: HttpStatusCode? {
            return HttpStatusCode(rawValue: code)
        }
        
        public var errorDescription: String? {
            return error
        }
    }
}
