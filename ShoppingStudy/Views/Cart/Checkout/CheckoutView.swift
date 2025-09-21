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
    @StateObject private var viewModel: CheckoutViewModel
    
    init(cartItems: [CartItem], totalAmount: Double, isGift: Bool,
         giftRecipient: User?, giftMessage: String) {
        self.cartItems = cartItems
        self.totalAmount = totalAmount
        self.isGift = isGift
        self.giftRecipient = giftRecipient
        self.giftMessage = giftMessage
        self._viewModel = StateObject(wrappedValue: CheckoutViewModel())
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.isProcessing {
                ProcessingPaymentView()
            } else if viewModel.showingSuccess {
                CheckoutSuccessView(
                    message: viewModel.successMessage,
                    orderId: viewModel.successOrderId,
                    onContinueShopping: {
                        dismiss()
                    }
                )
            } else {
                checkoutForm
            }
        }
    }
    
    private var checkoutForm: some View {
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
                    cardNumber: $viewModel.cardNumber,
                    cardholderName: $viewModel.cardholderName,
                    expiryDate: $viewModel.expiryDate,
                    cvv: $viewModel.cvv,
                    isFormValid: viewModel.isFormValid,
                    onPay: processPayment,
                    formatCardNumber: viewModel.formatCardNumber,
                    formatExpiryDate: viewModel.formatExpiryDate,
                    limitCVV: viewModel.limitCVV
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
        .alert("error".localized(), isPresented: $viewModel.showingError) {
            Button("ok".localized()) {
                viewModel.showingError = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private func processPayment() {
        Task {
            let success = await viewModel.processPayment(
                cartItems: cartItems,
                isGift: isGift,
                giftRecipient: giftRecipient,
                giftMessage: giftMessage,
                appState: appState
            )
            
            if !success {
                // Error is handled by the alert
            }
        }
    }
}
