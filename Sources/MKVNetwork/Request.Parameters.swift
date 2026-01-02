//
//  Request.Parameters.swift
//  MKVNetwork
//
//  Created by Татьяна Макеева on 16.03.2025.
//

import Foundation

public extension Request {
    struct Parameters: @unchecked Sendable {
        public enum Destination {
            case query
            case body
        }
        
        let destination: Destination
        let object: Any
        
        public static func query(_ query: Query<String>, encoding: QueryEncoding? = nil) -> Parameters {
            let encoding = encoding ?? QueryEncoding()
            let object = (query, encoding)
            return Parameters(destination: .query, object: object)
        }
        
        public static func body<T: Encodable>(_ object: T, encoder: JSONEncoder? = nil) throws -> Parameters {
            let encoder = encoder ?? JSONEncoder()
            let data = try encoder.encode(object)
            return Parameters(destination: .body, object: data)
        }
        
        public static func body(_ data: Data) -> Parameters {
            return Parameters(destination: .body, object: data)
        }
    }
}

public extension Request.Parameters {
    
    static func + (lhs: Request.Parameters, rhs: Request.Parameters?) -> Request.Parameters {
        guard let rhs = rhs else { return lhs }
        
        switch (lhs.destination, rhs.destination) {
        case (.query, .query):
            // Безопасно извлекаем объекты (Query<String>, QueryEncoding)
            guard
                let (lhsQuery, lhsEncoding) = lhs.object as? (Request.Query<String>, QueryEncoding),
                let (rhsQuery, _) = rhs.object as? (Request.Query<String>, QueryEncoding)
            else {
                // Если не можем распарсить — возвращаем rhs
                return rhs
            }
            
            // Объединяем элементы lhsQuery и rhsQuery вручную, т.к. метода merging нет
            var mergedElements = lhsQuery.elements
            for rhsParam in rhsQuery.elements {
                if let index = mergedElements.firstIndex(where: { $0.key == rhsParam.key }) {
                    mergedElements[index].value = rhsParam.value
                } else {
                    mergedElements.append(rhsParam)
                }
            }
            
            let mergedQuery = Request.Query<String>(uniqueKeysWithValues: mergedElements.map { ($0.key, $0.value) })
            return .query(mergedQuery, encoding: lhsEncoding)
            
        case (.body, .body):
            // Приоритет у правого параметра
            return rhs
            
        default:
            // Несовместимые destination — возвращаем rhs
            return rhs
        }
    }
    
    static func + (lhs: Request.Parameters, rhs: Request.Query<String>) -> Request.Parameters {
        switch lhs.destination {
        case .query:
            guard let (lhsQuery, lhsEncoding) = lhs.object as? (Request.Query<String>, QueryEncoding) else {
                return .query(rhs)
            }
            
            // Объединяем элементы вручную
            var mergedElements = lhsQuery.elements
            for rhsParam in rhs.elements {
                if let index = mergedElements.firstIndex(where: { $0.key == rhsParam.key }) {
                    mergedElements[index].value = rhsParam.value
                } else {
                    mergedElements.append(rhsParam)
                }
            }
            
            let mergedQuery = Request.Query<String>(uniqueKeysWithValues: mergedElements.map { ($0.key, $0.value) })
            return .query(mergedQuery, encoding: lhsEncoding)
            
        default:
            return .query(rhs)
        }
    }
}
