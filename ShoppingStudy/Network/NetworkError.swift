//
//  NetworkError.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case requestFailed(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "invalid_url".localized()
        case .invalidResponse:
            return "invalid_response".localized()
        case .serverError(let code):
            return "server_error".localized(with: code)
        case .requestFailed(let error):
            return "request_failed".localized(with: error.localizedDescription)
        case .decodingError(let error):
            return "decoding_error".localized(with: error.localizedDescription)
        }
    }
}
