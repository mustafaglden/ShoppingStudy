//
//  CartItem.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import Foundation

// Local model for cart items with product details
struct CartItem: Codable, Identifiable, Equatable {
    let id: String // UUID for local identification
    let productId: Int
    let product: Product
    var quantity: Int
    let addedDate: Date
    
    var totalPrice: Double {
        product.price * Double(quantity)
    }
    
    init(product: Product, quantity: Int) {
        self.id = UUID().uuidString
        self.productId = product.id
        self.product = product
        self.quantity = quantity
        self.addedDate = Date()
    }
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id
    }
}
