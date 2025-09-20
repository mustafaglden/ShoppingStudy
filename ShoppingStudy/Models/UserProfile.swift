//
//  UserProfile.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import Foundation

// Complete user profile with all statistics and data
struct UserProfile: Codable {
    let id: Int
    var username: String
    var email: String
    var favorites: Set<Int> // Product IDs
    var currentCart: [CartItem] // Current shopping cart items
    var purchaseHistory: [PurchaseHistory]
    var giftsReceived: [GiftRecord]
    var giftsSent: [GiftRecord]
    var totalPurchases: Double
    var totalItemsPurchased: Int
    var lastLoginDate: Date
    var preferredCurrency: String
    var preferredLanguage: String
    
    struct GiftRecord: Codable {
        let id: String
        let productIds: [Int]
        let fromUserId: Int?
        let toUserId: Int?
        let message: String?
        let date: Date
        let totalAmount: Double
    }
    
    init(id: Int, username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
        self.favorites = []
        self.currentCart = []
        self.purchaseHistory = []
        self.giftsReceived = []
        self.giftsSent = []
        self.totalPurchases = 0
        self.totalItemsPurchased = 0
        self.lastLoginDate = Date()
        self.preferredCurrency = Currency.usd.rawValue
        self.preferredLanguage = Language.english.rawValue
    }
}
