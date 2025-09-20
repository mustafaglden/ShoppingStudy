//
//  PurchaseHistory.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import Foundation

// MARK: - PurchaseHistory Model for Local Storage
struct PurchaseHistory: Codable, Identifiable {
    let id: String
    let orderId: Int // From API response
    let userId: Int
    let purchaseDate: Date
    let items: [PurchasedItem]
    let totalAmount: Double
    let currency: String
    let isGift: Bool
    let giftRecipient: User? // If it was a gift
    let giftMessage: String?
    
    struct PurchasedItem: Codable {
        let productId: Int
        let title: String
        let price: Double
        let quantity: Int
        let image: String
    }
    
    init(cartItems: [CartItem], orderId: Int, userId: Int, currency: String, isGift: Bool = false, recipient: User? = nil, message: String? = nil) {
        self.id = UUID().uuidString
        self.orderId = orderId
        self.userId = userId
        self.purchaseDate = Date()
        self.items = cartItems.map { item in
            PurchasedItem(
                productId: item.product.id,
                title: item.product.title,
                price: item.product.price,
                quantity: item.quantity,
                image: item.product.image
            )
        }
        self.totalAmount = cartItems.reduce(0) { $0 + $1.totalPrice }
        self.currency = currency
        self.isGift = isGift
        self.giftRecipient = recipient
        self.giftMessage = message
    }
}
