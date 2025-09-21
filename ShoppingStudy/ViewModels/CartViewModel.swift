//
//  CartViewModel.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

@MainActor
final class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var isLoading = false
    @Published var showingCheckout = false
    @Published var showingGiftOptions = false
    @Published var selectedGiftRecipient: User?
    @Published var giftMessage = ""
    @Published var isGiftMode = false
    @Published var showingSuccess = false
    @Published var successMessage = ""
    @Published var lastPurchaseId: Int?
    
    private let persistenceManager = UserPersistenceManager.shared
    private let cartService: CartServiceProtocol
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var itemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    init(cartService: CartServiceProtocol = CartService()) {
        self.cartService = cartService
    }
    
    func loadCart(userId: Int) {
        guard let user = persistenceManager.getUser(by: userId) else { return }
        self.cartItems = user.currentCart
    }
    
    func updateQuantity(itemId: String, quantity: Int, userId: Int, appState: AppState) {
        persistenceManager.updateCartItemQuantity(
            itemId: itemId,
            quantity: quantity,
            for: userId
        )
        loadCart(userId: userId)
        appState.updateCart()
    }
    
    func removeItem(itemId: String, userId: Int, appState: AppState) {
        persistenceManager.removeFromCart(itemId: itemId, for: userId)
        loadCart(userId: userId)
        appState.updateCart()
    }
    
    func clearCart(userId: Int, appState: AppState) {
        persistenceManager.clearCart(for: userId)
        loadCart(userId: userId)
        appState.updateCart()
    }
    
    func toggleGiftMode() {
        isGiftMode.toggle()
        if !isGiftMode {
            selectedGiftRecipient = nil
            giftMessage = ""
        }
    }
    
    func proceedToCheckout(userId: Int, currency: String, appState: AppState) async -> Bool {
        isLoading = true
        
        // Create cart request for API
        let cartProducts = cartItems.map { item in
            GetCartsResponse.CartProduct(
                productId: item.productId,
                quantity: item.quantity
            )
        }
        
        let cartRequest = AddCartRequest(
            userId: userId,
            date: ISO8601DateFormatter().string(from: Date()),
            products: cartProducts
        )
        
        do {
            // Send cart to API
            let response = try await cartService.addCart(cartRequest)
            
            // Store the purchase ID for later reference
            lastPurchaseId = response.id
            
            // Complete purchase locally
            persistenceManager.completePurchase(
                cart: cartItems,
                orderId: response.id,
                userId: userId,
                currency: currency,
                isGift: isGiftMode,
                recipient: selectedGiftRecipient,
                message: giftMessage
            )
            
            
            // Prepare success message
            if isGiftMode, let recipient = selectedGiftRecipient {
                successMessage = "gift_sent_successfully".localized() + "\n" +
                                "your_gift_has_been_sent_to".localized() + " " + recipient.displayName
            } else {
                successMessage = "order_completed".localized() + "\n" +
                               "order_number".localized(with: response.id)
            }
            
            // Update app state
            await MainActor.run {
                // Force reload user data to get updated purchase history
                appState.loadCurrentUser()
                appState.updateCart()
                
                // Clear cart items
                self.cartItems = []
                self.isGiftMode = false
                self.selectedGiftRecipient = nil
                self.giftMessage = ""
                self.isLoading = false
                
                // Show success
                self.showingSuccess = true
            }
            
            return true
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.successMessage = "payment_failed".localized()
            }
            return false
        }
    }
    
    func resetSuccessState() {
        showingSuccess = false
        successMessage = ""
    }
}

