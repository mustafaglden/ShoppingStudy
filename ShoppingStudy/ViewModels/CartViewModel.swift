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
    @Published var selectedGiftRecipient: User?
    @Published var giftMessage = ""
    @Published var isGiftMode = false
    @Published var showingSuccess = false
    @Published var successMessage = ""
    @Published var lastPurchaseId: Int?
    @Published var checkoutCompleted = false
    @Published var showingRemoveAlert = false
    @Published var itemToDelete: CartItem?
    @Published var showingClearCartAlert = false
    @Published var showingGiftSelector = false
    
    private let persistenceManager: UserPersistenceManagerProtocol
    private let cartService: CartServiceProtocol
    
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var itemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    init(persistenceManager: UserPersistenceManagerProtocol = UserPersistenceManager.shared,
         cartService: CartServiceProtocol = CartService()) {
        self.persistenceManager = persistenceManager
        self.cartService = cartService
    }
    
    func loadCart(userId: Int) {
        guard let user = persistenceManager.getUser(by: userId) else { return }
        self.cartItems = user.currentCart
    }
    
    func updateQuantity(itemId: String, quantity: Int, userId: Int, appState: AppStateProtocol) {
        persistenceManager.updateCartItemQuantity(
            itemId: itemId,
            quantity: quantity,
            for: userId
        )
        loadCart(userId: userId)
        appState.updateCart()
    }
    
    func prepareToRemoveItem(_ item: CartItem) {
        itemToDelete = item
        showingRemoveAlert = true
    }
    
    func confirmRemoveItem(userId: Int, appState: AppStateProtocol) {
        guard let item = itemToDelete else { return }
        persistenceManager.removeFromCart(itemId: item.id, for: userId)
        loadCart(userId: userId)
        appState.updateCart()
        itemToDelete = nil
        showingRemoveAlert = false
    }
    
    func cancelRemoveItem() {
        itemToDelete = nil
        showingRemoveAlert = false
    }
    
    func showClearCartConfirmation() {
        showingClearCartAlert = true
    }
    
    func confirmClearCart(userId: Int, appState: AppStateProtocol) {
        persistenceManager.clearCart(for: userId)
        loadCart(userId: userId)
        appState.updateCart()
        showingClearCartAlert = false
    }
    
    func toggleGiftMode() {
        isGiftMode.toggle()
        if isGiftMode {
            showingGiftSelector = true
        } else {
            selectedGiftRecipient = nil
            giftMessage = ""
        }
    }
    
    func showGiftSelector() {
        showingGiftSelector = true
    }
    
    func proceedToCheckout(userId: Int, currency: String, appState: AppStateProtocol) async -> Bool {
        isLoading = true
        checkoutCompleted = false
        
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
            let response = try await cartService.addCart(cartRequest)
            lastPurchaseId = response.id
            
            persistenceManager.completePurchase(
                cart: cartItems,
                orderId: response.id,
                userId: userId,
                currency: currency,
                isGift: isGiftMode,
                recipient: selectedGiftRecipient,
                message: giftMessage
            )
            
            if isGiftMode, let recipient = selectedGiftRecipient {
                successMessage = "gift_sent_successfully".localized() + "\n" +
                                "your_gift_has_been_sent_to".localized() + " " + recipient.displayName
            } else {
                successMessage = "order_completed".localized() + "\n" +
                               "thank_you_purchase".localized()
            }
            
            await MainActor.run {
                appState.loadCurrentUser()
                appState.updateCart()
                self.cartItems = []
                self.isGiftMode = false
                self.selectedGiftRecipient = nil
                self.giftMessage = ""
                self.isLoading = false
                self.showingSuccess = true
                self.checkoutCompleted = true
            }
            
            return true
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.successMessage = "payment_failed".localized()
                self.showingSuccess = true
            }
            return false
        }
    }
    
    func resetState() {
        showingSuccess = false
        successMessage = ""
        checkoutCompleted = false
    }
}
