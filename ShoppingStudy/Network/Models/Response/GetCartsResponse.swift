//
//  GetCartsResponse.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import Foundation

// Response from GET /carts/user/{userId} - array of cart objects
struct GetCartsResponse: Codable, Identifiable {
    let id: Int
    let userId: Int
    let date: String
    let products: [CartProduct]
    
    struct CartProduct: Codable {
        let productId: Int
        let quantity: Int
    }
}
