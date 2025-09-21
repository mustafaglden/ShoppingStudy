//
//  MockProductService.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import Foundation
@testable import ShoppingStudy

class MockProductService: ProductServiceProtocol {
    var mockProducts: [Product] = []
    var mockCategories: [String] = ["electronics", "clothing"]
    var shouldFail = false
    var fetchProductsCalled = false
    var fetchCategoriesCalled = false
    
    func fetchProducts(limit: Int?, sort: String?, category: String?) async throws -> [Product] {
        fetchProductsCalled = true
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
        fetchCategoriesCalled = true
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "Test", code: -1))
        }
        return mockCategories
    }
}
