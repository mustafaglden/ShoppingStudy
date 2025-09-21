//
//  MockProductService.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import XCTest
@testable import ShoppingStudy

class MockProductService: ProductServiceProtocol {
    var mockProducts: [Product] = []
    var mockCategories: [String] = ["electronics", "clothing"]
    var shouldFail = false
    
    func fetchProducts(limit: Int?, sort: String?, category: String?) async throws -> [Product] {
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "Test", code: -1))
        }
        return mockProducts
    }
    
    func fetchProductDetail(id: Int) async throws -> Product {
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "Test", code: -1))
        }
        return mockProducts.first { $0.id == id } ?? mockProducts[0]
    }
    
    func fetchCategories() async throws -> [String] {
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "Test", code: -1))
        }
        return mockCategories
    }
}
