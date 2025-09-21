//
//  MockCartService.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//


import Foundation
@testable import ShoppingStudy

class MockCartService: CartServiceProtocol {
    var mockResponse: AddCartResponse?
    var mockCarts: [GetCartsResponse] = []
    var shouldFail = false
    var addCartCalled = false
    
    func addCart(_ cartRequest: AddCartRequest) async throws -> AddCartResponse {
        addCartCalled = true
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "Test", code: -1))
        }
        return mockResponse ?? AddCartResponse(
            id: 123,
            userId: cartRequest.userId,
            date: cartRequest.date,
            products: []
        )
    }
    
    func getUserCarts(userId: Int) async throws -> [GetCartsResponse] {
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "Test", code: -1))
        }
        return mockCarts
    }
}
