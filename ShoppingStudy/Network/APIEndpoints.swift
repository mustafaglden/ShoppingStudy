//
//  APIEndpoints.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

enum APIEndpoints {
    static let baseURL = "https://fakestoreapi.com"
    static let exchangeRateBaseURL = "https://v6.exchangerate-api.com/v6"
    static let exchangeRateAPIKey = "4a42e4a3996c793e4a49203e"
    
    case products
    case product(Int)
    case categories
    case category(String)
    case login
    case users
    case user(Int)
    case carts
    case cart(Int)
    case userCarts(Int)
    case exchangeRates(String)
    
    var url: String {
        switch self {
        case .products:
            return "\(APIEndpoints.baseURL)/products"
        case .product(let id):
            return "\(APIEndpoints.baseURL)/products/\(id)"
        case .categories:
            return "\(APIEndpoints.baseURL)/products/categories"
        case .category(let category):
            return "\(APIEndpoints.baseURL)/products/category/\(category)"
        case .login:
            return "\(APIEndpoints.baseURL)/auth/login"
        case .users:
            return "\(APIEndpoints.baseURL)/users"
        case .user(let id):
            return "\(APIEndpoints.baseURL)/users/\(id)"
        case .carts:
            return "\(APIEndpoints.baseURL)/carts"
        case .cart(let id):
            return "\(APIEndpoints.baseURL)/carts/\(id)"
        case .userCarts(let userId):
            return "\(APIEndpoints.baseURL)/carts/user/\(userId)"
        case .exchangeRates(let baseCurrency):
            return "\(APIEndpoints.exchangeRateBaseURL)/\(APIEndpoints.exchangeRateAPIKey)/latest/\(baseCurrency)"
        }
    }
}
