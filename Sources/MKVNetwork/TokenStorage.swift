//
//  TokenStorage.swift
//  Storage
//
//  Created by Татьяна Макеева on 11.07.2025.
//

import Foundation

public protocol TokenStorage: Sendable {
    func getToken() -> String?
    func saveToken(_ token: String) throws
    func removeToken() throws
}
