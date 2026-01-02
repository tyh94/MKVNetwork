//
//  AuthorizedNetwork.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 16.07.2025.
//

import Foundation

extension NetworkManaging {
    public func authorized(
        authorizationHeaderProvider: @escaping @Sendable (String) -> HTTPHeader,
        tokenStorage: TokenStorage,
        tokenRefresher: TokenRefreshHandler?,
        logger: Logger?
    ) -> NetworkManaging {
        AuthorizedNetwork(
            loader: self,
            authorizationHeaderProvider: authorizationHeaderProvider,
            tokenStorage: tokenStorage,
            tokenRefresher: tokenRefresher,
            logger: logger
        )
    }
}

public final class AuthorizedNetwork: NetworkManaging {
    enum Error: Swift.Error {
        case notAuthorized
    }
    private let loader: NetworkManaging
    private let authorizationHeaderProvider: @Sendable (String) -> HTTPHeader
    private let tokenStorage: TokenStorage
    private let tokenRefresher: TokenRefreshHandler?
    private let logger: Logger?

    public init(
        loader: NetworkManaging,
        authorizationHeaderProvider: @escaping @Sendable (String) -> HTTPHeader,
        tokenStorage: TokenStorage,
        tokenRefresher: TokenRefreshHandler?,
        logger: Logger?
    ) {
        self.loader = loader
        self.authorizationHeaderProvider = authorizationHeaderProvider
        self.tokenStorage = tokenStorage
        self.tokenRefresher = tokenRefresher
        self.logger = logger
    }

    public func dataRequest<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil,
        decoder: JSONDecoder? = nil
    ) async throws -> T {
        try await authorizedRequest {
            try await self.loader.dataRequest(
                url: url,
                method: method,
                headers: headers + [self.authorizationHeaderProvider($0)],
                parameters: parameters,
                decoder: decoder
            )
        }
    }

    @discardableResult
    public func dataRequest(
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil,
    ) async throws -> Data {
        try await authorizedRequest { [self] in
            try await self.loader.dataRequest(
                url: url,
                method: method,
                headers: headers + [self.authorizationHeaderProvider($0)],
                parameters: parameters
            )
        }
    }
    
    public func uploadRequest<T: Decodable>(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameters: Request.Parameters?,
        decoder: JSONDecoder?
    ) async throws -> T {
        try await authorizedRequest { [self] in
            try await self.loader.uploadRequest(
                data: data,
                url: url,
                method: method,
                headers: headers + [self.authorizationHeaderProvider($0)],
                parameters: parameters,
                decoder: decoder
            )
        }
    }

    public func uploadRequest(
        data: Data,
        url: URL,
        method: HTTPMethod,
        headers: [HTTPHeader] = [],
        parameters: Request.Parameters? = nil
    ) async throws -> Data {
        try await authorizedRequest { [self] in
            try await self.loader.uploadRequest(
                data: data,
                url: url,
                method: method,
                headers: headers + [self.authorizationHeaderProvider($0)],
                parameters: parameters
            )
        }
    }

    // MARK: - Обёртка с авторизацией и рефрешем токена

    @discardableResult
    private func authorizedRequest<T>(_ operation: @escaping (String) async throws -> T) async throws -> T {
        guard var token = tokenStorage.getToken() else {
            throw Error.notAuthorized
        }

        do {
            return try await operation(token)
        } catch {
            if shouldRefreshToken(for: error), let tokenRefresher {
                logger?.debug("⟳ Attempting to refresh token due to error: \(error.localizedDescription)")
                
                token = try await tokenRefresher.refreshToken()
                try tokenStorage.saveToken(token)
                
                logger?.debug("✅ Token refreshed. Retrying operation.")
                return try await operation(token)
            } else {
                throw error
            }
        }
    }
    
    private func shouldRefreshToken(for error: Swift.Error) -> Bool {
        if let urlError = error as? URLError,
           let response = urlError.userInfo[NSURLErrorFailingURLErrorKey] as? HTTPURLResponse {
            return [401, 403].contains(response.statusCode)
        }

        if let networkError = error as? NetworkError {
            return [401, 403].contains(networkError.statusCode)
        }

        if let driveError = error as? GoogleDriveError {
            return [401, 403].contains(driveError.error.code)
        }

        return false
    }
}
