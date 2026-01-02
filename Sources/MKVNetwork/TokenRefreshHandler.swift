//
//  TokenRefreshHandler.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 16.07.2025.
//

import Foundation

public protocol TokenRefreshHandler: AnyObject, Sendable {
    func refreshToken() async throws -> String
}
