//
//  CheckoutView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct CheckoutView: View {
    let cartItems: [CartItem]
    let totalAmount: Double
    let isGift: Bool
    let giftRecipient: User?
    let giftMessage: String
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var cardNumber = ""
    @State private var cardholderName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var showingSuccess = false
    @State private var successOrderId: Int?
    
    private let cartViewModel = CartViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    OrderSummaryView(
                        cartItems: cartItems,
                        totalAmount: totalAmount,
                        appState: appState
                    )
                    
                    if isGift, let recipient = giftRecipient {
                        GiftInfoView(
                            recipient: recipient,
                            giftMessage: giftMessage
                        )
                    }
                    
                    PaymentFormView(
                        cardNumber: $cardNumber,
                        cardholderName: $cardholderName,
                        expiryDate: $expiryDate,
                        cvv: $cvv,
                        onPay: processPayment
                    )
                }
                .padding()
            }
            .navigationTitle("checkout".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized()) {
                        dismiss()
                    }
                }
            }
            .alert("success".localized(), isPresented: $showingSuccess) {
                Button("continue_shopping".localized()) {
                    appState.loadCurrentUser()
                    dismiss()
                }
            } message: {
                successAlertMessage
            }
        }
    }
    
    // Alert message
    private var successAlertMessage: some View {
        if isGift, let recipient = giftRecipient {
            let msg = "gift_sent_successfully".localized() + "\n" +
                      "your_gift_has_been_sent_to".localized() + " " + recipient.displayName
            return Text(msg)
        } else {
            let msg = "order_completed".localized() + "\n" +
                      "thank_you_purchase".localized()
            return Text(msg)
        }
    }
    
    private func processPayment() {
        cartViewModel.cartItems = cartItems
        cartViewModel.isGiftMode = isGift
        cartViewModel.selectedGiftRecipient = giftRecipient
        cartViewModel.giftMessage = giftMessage
        
        Task {
            let success = await cartViewModel.proceedToCheckout(
                userId: appState.currentUser?.id ?? 0,
                currency: appState.currentCurrency.rawValue,
                appState: appState
            )
            
            await MainActor.run {
                if success {
                    successOrderId = cartViewModel.lastPurchaseId
                    appState.loadCurrentUser()
                    showingSuccess = true
                }
            }
        }
    }
}
