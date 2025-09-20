//
//  UserPersistenceManager.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import Foundation

final class UserPersistenceManager {
    static let shared = UserPersistenceManager()
    
    private let userDefaultsKey = "com.shoppingStudy.userProfiles"
    private let currentUserKey = "com.shoppingStudy.currentUserId"
    private let lastUserIdKey = "com.shoppingStudy.lastUserId"
    
    private init() {}
    
    // MARK: - User Management
    func createUser(username: String, email: String) -> UserProfile {
        let userId = generateNextUserId()
        let newUser = UserProfile(id: userId, username: username, email: email)
        saveUser(newUser)
        return newUser
    }
    
    func getCurrentUser() -> UserProfile? {
        guard let userId = UserDefaults.standard.object(forKey: currentUserKey) as? Int else {
            return nil
        }
        return getUser(by: userId)
    }
    
    func setCurrentUser(_ userId: Int) {
        UserDefaults.standard.set(userId, forKey: currentUserKey)
    }
    
    func getUser(by id: Int) -> UserProfile? {
        let users = getAllUsers()
        return users.first { $0.id == id }
    }
    
    func getUser(by username: String, password: String) -> UserProfile? {
        let users = getAllUsers()
        return users.first { $0.username == username }
    }
    
    func saveUser(_ user: UserProfile) {
        var users = getAllUsers()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        } else {
            users.append(user)
        }
        saveAllUsers(users)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    // MARK: - Cart Management
    
    func addToCart(product: Product, quantity: Int, for userId: Int) {
        guard var user = getUser(by: userId) else { return }
        
        if let existingIndex = user.currentCart.firstIndex(where: { $0.productId == product.id }) {
            user.currentCart[existingIndex].quantity += quantity
        } else {
            let cartItem = CartItem(product: product, quantity: quantity)
            user.currentCart.append(cartItem)
        }
        
        saveUser(user)
    }
    
    func updateCartItemQuantity(itemId: String, quantity: Int, for userId: Int) {
        guard var user = getUser(by: userId),
              let index = user.currentCart.firstIndex(where: { $0.id == itemId }) else { return }
        
        if quantity <= 0 {
            user.currentCart.remove(at: index)
        } else {
            user.currentCart[index].quantity = quantity
        }
        
        saveUser(user)
    }
    
    func removeFromCart(itemId: String, for userId: Int) {
        guard var user = getUser(by: userId) else { return }
        user.currentCart.removeAll { $0.id == itemId }
        saveUser(user)
    }
    
    func clearCart(for userId: Int) {
        guard var user = getUser(by: userId) else { return }
        user.currentCart.removeAll()
        saveUser(user)
    }
    
    // MARK: - Favorites Management
    
    func toggleFavorite(productId: Int, for userId: Int) -> Bool {
        guard var user = getUser(by: userId) else { return false }
        
        if user.favorites.contains(productId) {
            user.favorites.remove(productId)
            saveUser(user)
            return false
        } else {
            user.favorites.insert(productId)
            saveUser(user)
            return true
        }
    }
    
    func isFavorite(productId: Int, for userId: Int) -> Bool {
        guard let user = getUser(by: userId) else { return false }
        return user.favorites.contains(productId)
    }
    
    // MARK: - Purchase Management
    
    func completePurchase(cart: [CartItem], orderId: Int, userId: Int, currency: String, isGift: Bool = false, recipient: User? = nil, message: String? = nil) {
        guard var user = getUser(by: userId) else { return }
        
        let purchase = PurchaseHistory(
            cartItems: cart,
            orderId: orderId,
            userId: userId,
            currency: currency,
            isGift: isGift,
            recipient: recipient,
            message: message
        )
        
        user.purchaseHistory.append(purchase)
        user.totalPurchases += purchase.totalAmount
        user.totalItemsPurchased += cart.reduce(0) { $0 + $1.quantity }
        
        // If it's a gift, update gift records
        if isGift, let recipient = recipient {
            let giftRecord = UserProfile.GiftRecord(
                id: UUID().uuidString,
                productIds: cart.map { $0.productId },
                fromUserId: userId,
                toUserId: recipient.id,
                message: message,
                date: Date(),
                totalAmount: purchase.totalAmount
            )
            
            user.giftsSent.append(giftRecord)
            
            // Update recipient's received gifts
            if var recipientUser = getUser(by: recipient.id) {
                recipientUser.giftsReceived.append(giftRecord)
                saveUser(recipientUser)
            }
        }
        
        // Clear the cart after purchase
        user.currentCart.removeAll()
        saveUser(user)
    }
    
    // MARK: - Settings Management
    
    func updateUserSettings(userId: Int, currency: String? = nil, language: String? = nil) {
        guard var user = getUser(by: userId) else { return }
        
        if let currency = currency {
            user.preferredCurrency = currency
        }
        
        if let language = language {
            user.preferredLanguage = language
        }
        
        saveUser(user)
    }
    
    // MARK: - Private Helpers
    
    private func getAllUsers() -> [UserProfile] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let users = try? JSONDecoder().decode([UserProfile].self, from: data) else {
            return []
        }
        return users
    }
    
    private func saveAllUsers(_ users: [UserProfile]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func generateNextUserId() -> Int {
        let lastId = UserDefaults.standard.integer(forKey: lastUserIdKey)
        let newId = lastId + 1
        UserDefaults.standard.set(newId, forKey: lastUserIdKey)
        return newId
    }
}
