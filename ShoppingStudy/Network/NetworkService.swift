//
//  NetworkService.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

final class NetworkService: NetworkManager {
    static let shared = NetworkService()
    
    private init() {}
    
    func makeRequest<T: APIRequest>(_ request: T) async throws -> T.ResponseType {
        guard let url = URL(string: request.endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            let decodedData = try JSONDecoder().decode(T.ResponseType.self, from: data)
            return decodedData
        } catch {
            if error is DecodingError {
                throw NetworkError.decodingError(error)
            }
            throw NetworkError.requestFailed(error)
        }
    }
}
