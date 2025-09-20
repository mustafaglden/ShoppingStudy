//
//  AuthService.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

protocol AuthServiceProtocol {
    func login(username: String, password: String) async throws -> User
    func register(parameters: RegisterRequestParameters) async throws -> User
}

final class AuthService: AuthServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkService.shared) {
        self.networkManager = networkManager
    }
    
    func login(username: String, password: String) async throws -> User {
        let loginRequest = try LoginAPIRequest(username: username, password: password)
        _ = try await networkManager.makeRequest(loginRequest)
        
        return User(
            id: 1,
            email: username.contains("@") ? username : "\(username)@example.com",
            username: username,
            password: nil
        )
    }
    
    func register(parameters: RegisterRequestParameters) async throws -> User {
        let registerAPIRequest = try RegisterAPIRequest(parameters: parameters)
        let created = try await networkManager.makeRequest(registerAPIRequest)

        return User(
            id: created.id ?? 0,
            email: created.email ?? parameters.email,
            username: created.username ?? parameters.username,
            password: nil
        )
    }
}
