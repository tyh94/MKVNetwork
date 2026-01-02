//
//  TokenStorageMock.swift
//  Storage
//
//  Created by Татьяна Макеева on 14.07.2025.
//

import Foundation

public struct TokenStorageMock: TokenStorage {
    public init() {}
    
    public func getToken() -> String? {
        nil
    }
    
    public func saveToken(_ token: String) throws {
        
    }
    
    public func removeToken() throws {
        
    }
}
