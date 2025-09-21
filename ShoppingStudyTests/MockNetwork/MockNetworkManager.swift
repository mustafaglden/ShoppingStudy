//
//  MockNetworkManager.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import Foundation
@testable import ShoppingStudy


// Mock Objects
class MockNetworkManager: NetworkManager {
    var shouldFail = false
    var mockResponse: Any?
    
    func makeRequest<T: APIRequest>(_ request: T) async throws -> T.ResponseType {
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "Test", code: -1))
        }
        
        if let response = mockResponse as? T.ResponseType {
            return response
        }
        
        throw NetworkError.invalidResponse
    }
}
