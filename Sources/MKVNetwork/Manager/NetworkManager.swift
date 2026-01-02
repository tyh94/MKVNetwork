//
//  NetworkManager.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 16.03.2025.
//

import Foundation

public final class NetworkManager: Sendable {
    let session: URLSession
    let timeoutInterval: TimeInterval
    
    public init(
        session: URLSession = .shared,
        timeoutInterval: TimeInterval = 30.0
    ) {
        self.session = session
        self.timeoutInterval = timeoutInterval
    }
    
    public func handle<T>(response: URLResponse, content: T) throws -> T {
        guard let response = response as? HTTPURLResponse else {
            throw "Unknown response received"
        }
        
        guard let httpStatus = HttpStatusCode(rawValue: response.statusCode) else {
            throw "Unknown http status code"
        }
        
        if httpStatus.isSuccessStatusCode {
            return content
        }
        // Обработка ошибок
        guard let responseData = content as? Data else {
            throw NetworkError.noErrorData(status: httpStatus)
        }
        
        // Пытаемся декодировать как Google Drive ошибку
        if let googleError = try? JSONDecoder().decode(GoogleDriveError.self, from: responseData) {
            throw googleError
        }
        
        // Пытаемся декодировать как стандартную ошибку
        if let standardError = try? JSONDecoder().decode(Request.Error.self, from: responseData) {
            throw standardError
        }
        
        // Все остальные случаи
        throw NetworkError.serverError(
            status: httpStatus,
            data: responseData
        )
    }
}

public struct GoogleDriveError: LocalizedError, Decodable, Sendable {
    public struct ErrorDetail: Decodable, Sendable {
        public let domain: String
        public let reason: String
        public let message: String
    }
    
    public struct ErrorResponse: Decodable, Sendable {
        public let code: Int
        public let message: String
        public let errors: [ErrorDetail]?
    }
    
    public let error: ErrorResponse
    
    public var statusCode: HttpStatusCode? {
        HttpStatusCode(rawValue: error.code)
    }
    
    public var errorDescription: String? {
        error.message
    }
    
    public var detailedDescription: String {
        error.errors?.first?.message ?? error.message
    }
}

public enum NetworkError: LocalizedError, Sendable {
    case unknownResponse
    case invalidStatusCode(Int)
    case noErrorData(status: HttpStatusCode)
    case serverError(status: HttpStatusCode, data: Data)
    case decodingError(Error)
    case timeout
    case noInternetConnection
    case connectionLost
    case cancelled
    case badURL
    case unsupportedURL
    case hostUnreachable
    case dnsLookupFailed
    case unknown(error: Error)
    
    public var errorDescription: String? {
        switch self {
        case .unknownResponse:
            return "Неизвестный формат ответа сервера"
        case .invalidStatusCode(let code):
            return "Неизвестный HTTP статус код: \(code)"
        case .noErrorData(let status):
            return "Ошибка \(status.rawValue): \(status.stringValue)"
        case .serverError(let status, let data):
            let body = String(data: data, encoding: .utf8) ?? "Нечитаемый формат"
            return "Ошибка \(status.rawValue): \(status.stringValue)\nТело ответа: \(body)"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .timeout:
            return "Превышено время ожидания ответа от сервера"
        case .noInternetConnection:
            return "Отсутствует подключение к интернету"
        case .connectionLost:
            return "Соединение с сервером было потеряно"
        case .cancelled:
            return "Запрос был отменен"
        case .badURL:
            return "Некорректный URL адрес"
        case .unsupportedURL:
            return "Неподдерживаемый URL адрес"
        case .hostUnreachable:
            return "Сервер недоступен"
        case .dnsLookupFailed:
            return "Не удалось найти сервер"
        case .unknown(let error):
            return "Неизвестная ошибка: \(error.localizedDescription)"
        }
    }
    
    public var statusCode: Int? {
        switch self {
        case .serverError(let status, _),
             .noErrorData(let status):
            return status.rawValue
        default:
            return nil
        }
    }
    
    // Добавим свойство для удобного доступа к HttpStatusCode
    public var httpStatus: HttpStatusCode? {
        switch self {
        case .serverError(let status, _),
             .noErrorData(let status):
            return status
        case .invalidStatusCode(let code):
            return HttpStatusCode(rawValue: code)
        default:
            return nil
        }
    }
}
