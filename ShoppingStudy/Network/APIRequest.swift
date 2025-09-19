//
//  APIRequest.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

protocol APIRequest {
    associatedtype ResponseType: Decodable
    
    var endpoint: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension APIRequest {
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var body: Data? { nil }
}
