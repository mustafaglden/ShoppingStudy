//
//  AddCartRequest.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import Foundation

struct AddCartRequest: Codable {
    let userId: Int
    let date: String
    let products: [GetCartsResponse.CartProduct]
}

struct AddCartAPIRequest: APIRequest {
    typealias ResponseType = AddCartResponse
    
    let endpoint = APIEndpoints.carts.url
    let method: HTTPMethod = .post
    let body: Data?
    
    init(cartRequest: AddCartRequest) throws {
        self.body = try JSONEncoder().encode(cartRequest)
    }
}
