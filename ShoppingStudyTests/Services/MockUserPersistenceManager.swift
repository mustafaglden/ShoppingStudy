//
//  MockUserPersistenceManager.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import Foundation
@testable import ShoppingStudy

class MockUserPersistenceManager: UserPersistenceManagerProtocol {
    var mockUser: UserProfile?
    var users: [UserProfile] = []
    var setCurrentUserCalled = false
    var getUserCalled = false
    var logoutCalled = false
    var saveUserCalled = false
    var completePurchaseCalled = false
    var lastCompletedPurchase: (cart: [CartItem], orderId: Int, userId: Int)?
    
    func createUser(username: String, email: String) -> UserProfile {
        let user = UserProfile(id: users.count + 1, username: username, email: email)
        users.append(user)
        return user
    }
    
    func getCurrentUser() -> UserProfile? {
        return mockUser
    }
    
    func setCurrentUser(_ userId: Int) {
        setCurrentUserCalled = true
        mockUser = users.first { $0.id == userId }
    }
    
    func getUser(by id: Int) -> UserProfile? {
        getUserCalled = true
        return users.first { $0.id == id } ?? mockUser
    }
    
    func getUser(by username: String, password: String) -> UserProfile? {
        return users.first { $0.username == username } ?? mockUser
    }
    
    func saveUser(_ user: UserProfile) {
        saveUserCalled = true
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        } else {
            users.append(user)
        }
        mockUser = user
    }
    
    func logout() {
        logoutCalled = true
        mockUser = nil
    }
    
    func addToCart(product: Product, quantity: Int, for userId: Int) {
        guard var user = getUser(by: userId) else { return }
        let cartItem = CartItem(product: product, quantity: quantity)
        user.currentCart.append(cartItem)
        saveUser(user)
    }
    
    func updateCartItemQuantity(itemId: String, quantity: Int, for userId: Int) {
        guard var user = getUser(by: userId),
              let index = user.currentCart.firstIndex(where: { $0.id == itemId }) else { return }
        user.currentCart[index].quantity = quantity
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
    
    func completePurchase(cart: [CartItem], orderId: Int, userId: Int, currency: String, 
                         isGift: Bool, recipient: User?, message: String?) {
        completePurchaseCalled = true
        lastCompletedPurchase = (cart, orderId, userId)
        
        guard var user = getUser(by: userId) else { return }
        user.currentCart.removeAll()
        user.totalPurchases += cart.reduce(0) { $0 + $1.totalPrice }
        saveUser(user)
    }
    
    func updateUserSettings(userId: Int, currency: String?, language: String?) {
        guard var user = getUser(by: userId) else { return }
        if let currency = currency {
            user.preferredCurrency = currency
        }
        if let language = language {
            user.preferredLanguage = language
        }
        saveUser(user)
    }
}
