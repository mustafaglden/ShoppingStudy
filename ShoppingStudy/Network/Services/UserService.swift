//
//  UserService.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import Foundation

protocol UserServiceProtocol {
    func fetchAllUsers() async throws -> [User]
    func fetchUser(by id: Int) async throws -> User
}

final class UserService: UserServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkService.shared) {
        self.networkManager = networkManager
    }
    
    func fetchAllUsers() async throws -> [User] {
        let request = UsersRequest()
        let users = try await networkManager.makeRequest(request)
        return users
    }
    
    func fetchUser(by id: Int) async throws -> User {
        let request = SingleUserRequest(userId: id)
        let user = try await networkManager.makeRequest(request)
        return user
    }
}
