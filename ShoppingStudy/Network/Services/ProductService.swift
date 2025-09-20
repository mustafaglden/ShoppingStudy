//
//  ProductService.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 19.09.2025.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(limit: Int?, sort: String?, category: String?) async throws -> [Product]
    func fetchProductDetail(id: Int) async throws -> Product
    func fetchCategories() async throws -> [String]
}

final class ProductService: ProductServiceProtocol {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkService.shared) {
        self.networkManager = networkManager
    }
    
    // If category selected fill category param. 
    func fetchProducts(limit: Int?, sort: String?, category: String?) async throws -> [Product] {
        let request = ProductListRequest(limit: limit, sort: sort, category: category)
        return try await networkManager.makeRequest(request)
    }
    
    func fetchProductDetail(id: Int) async throws -> Product {
        let request = ProductDetailRequest(id: id)
        return try await networkManager.makeRequest(request)
    }
    
    func fetchCategories() async throws -> [String] {
        let request = CategoriesRequest()
        return try await networkManager.makeRequest(request)
    }
}
