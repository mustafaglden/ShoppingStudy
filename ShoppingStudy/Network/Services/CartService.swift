//
//  CartServiceProtocol.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import Foundation

protocol CartServiceProtocol {
    func addCart(_ cartRequest: AddCartRequest) async throws -> AddCartResponse
    func getUserCarts(userId: Int) async throws -> [GetCartsResponse]
}

final class CartService: CartServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkService.shared) {
        self.networkManager = networkManager
    }
    
    func addCart(_ cartRequest: AddCartRequest) async throws -> AddCartResponse {
        let request = try AddCartAPIRequest(cartRequest: cartRequest)
        return try await networkManager.makeRequest(request)
    }
    
    func getUserCarts(userId: Int) async throws -> [GetCartsResponse] {
        let request = GetUserCartsRequest(userId: userId)
        return try await networkManager.makeRequest(request)
    }
}
