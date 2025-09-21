//
//  CheckoutViewModel.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import SwiftUI

@MainActor
final class CheckoutViewModel: ObservableObject {
    @Published var cardNumber = ""
    @Published var cardholderName = ""
    @Published var expiryDate = ""
    @Published var cvv = ""
    @Published var isProcessing = false
    @Published var showingSuccess = false
    @Published var successMessage = ""
    @Published var successOrderId: Int?
    @Published var showingError = false
    @Published var errorMessage = ""
    
    private let cartService: CartServiceProtocol
    private let persistenceManager: UserPersistenceManagerProtocol
    
    var isFormValid: Bool {
        !cardNumber.isEmpty &&
        cardNumber.replacingOccurrences(of: " ", with: "").count >= 16 &&
        !cardholderName.isEmpty &&
        expiryDate.count == 5 &&
        cvv.count >= 3
    }
    
    init(cartService: CartServiceProtocol = CartService(),
         persistenceManager: UserPersistenceManagerProtocol = UserPersistenceManager.shared) {
        self.cartService = cartService
        self.persistenceManager = persistenceManager
    }
    
    func formatCardNumber(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: " ", with: "")
        let truncated = String(cleaned.prefix(16))
        
        var formatted = ""
        for (index, character) in truncated.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(character)
        }
        return formatted
    }
    
    func formatExpiryDate(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: "/", with: "")
        let truncated = String(cleaned.prefix(4))
        
        if truncated.count >= 3 {
            let month = String(truncated.prefix(2))
            let year = String(truncated.suffix(truncated.count - 2))
            return "\(month)/\(year)"
        }
        return truncated
    }
    
    func limitCVV(_ value: String) -> String {
        return String(value.prefix(4))
    }
    
    func processPayment(cartItems: [CartItem], isGift: Bool, giftRecipient: User?,
                       giftMessage: String, appState: AppStateProtocol) async -> Bool {
        isProcessing = true
        showingError = false
        
        guard let userId = appState.currentUser?.id else {
            isProcessing = false
            errorMessage = "User not found"
            showingError = true
            return false
        }
        
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
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            let response = try await cartService.addCart(cartRequest)
            successOrderId = response.id
            
            persistenceManager.completePurchase(
                cart: cartItems,
                orderId: response.id,
                userId: userId,
                currency: appState.currentCurrency.rawValue,
                isGift: isGift,
                recipient: giftRecipient,
                message: giftMessage
            )
            
            if isGift, let recipient = giftRecipient {
                successMessage = "gift_sent_successfully".localized() + "\n" +
                                "your_gift_has_been_sent_to".localized() + " " + recipient.displayName
            } else {
                successMessage = "order_completed".localized() + "\n" +
                               "thank_you_purchase".localized()
            }
            
            appState.loadCurrentUser()
            appState.notifyPurchaseCompleted()
            
            await MainActor.run {
                self.isProcessing = false
                self.showingSuccess = true
            }
            
            return true
        } catch {
            await MainActor.run {
                self.isProcessing = false
                self.errorMessage = "payment_failed".localized()
                self.showingError = true
            }
            return false
        }
    }
}
