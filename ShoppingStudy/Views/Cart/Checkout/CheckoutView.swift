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
    @State private var isProcessing = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var successOrderId: Int?
    
    private let cartViewModel = CartViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Order Summary
                    orderSummarySection
                    
                    // Gift Info (if applicable)
                    if isGift, let recipient = giftRecipient {
                        giftInfoSection(recipient: recipient)
                    }
                    
                    // Payment Form
                    paymentFormSection
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
                    .disabled(isProcessing)
                }
            }
            .disabled(isProcessing)
            .overlay {
                if isProcessing {
                    processingOverlay
                }
            }
            .alert("success".localized(), isPresented: $showingSuccess) {
                Button("continue_shopping".localized()) {
                    // Force refresh the profile data
                    appState.loadCurrentUser()
//                    dismiss()
                }
            } message: {
                VStack {
                    if isGift {
                        Text("gift_sent_successfully".localized())
                        if let recipient = giftRecipient {
                            Text("your_gift_has_been_sent_to".localized() + " \(recipient.displayName)")
                        }
                    } else {
                        Text("thank_you_purchase".localized())
                    }
                    
                    if let orderId = successOrderId {
                        Text("order_number".localized(with: orderId))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert("error".localized(), isPresented: $showingError) {
                Button("ok".localized()) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("order_summary".localized())
                .font(.headline)
            
            VStack(spacing: 10) {
                ForEach(cartItems) { item in
                    HStack {
                        Text(item.product.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("x\(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(appState.formatPrice(item.totalPrice))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("total".localized())
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(appState.formatPrice(totalAmount))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private func giftInfoSection(recipient: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("gift".localized(), systemImage: "gift.fill")
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("recipient".localized() + ":")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(recipient.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if !giftMessage.isEmpty {
                    Text("message".localized() + ":")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(giftMessage)
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(10)
        }
    }
    
    private var paymentFormSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("payment_information".localized())
                .font(.headline)
            
            VStack(spacing: 15) {
                // Card Number
                VStack(alignment: .leading, spacing: 5) {
                    Text("card_number".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.gray)
                        TextField("1234 5678 9012 3456", text: $cardNumber)
                            .keyboardType(.numberPad)
                            .onChange(of: cardNumber) { _, newValue in
                                cardNumber = formatCardNumber(newValue)
                            }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Cardholder Name
                VStack(alignment: .leading, spacing: 5) {
                    Text("cardholder_name".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                        TextField("John Doe", text: $cardholderName)
                            .autocapitalization(.words)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Expiry and CVV
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("mm_yy".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            TextField("MM/YY", text: $expiryDate)
                                .keyboardType(.numberPad)
                                .onChange(of: expiryDate) { _, newValue in
                                    expiryDate = formatExpiryDate(newValue)
                                }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("cvv".localized())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            TextField("123", text: $cvv)
                                .keyboardType(.numberPad)
                                .onChange(of: cvv) { _, newValue in
                                    cvv = String(newValue.prefix(4))
                                }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Pay Button
                Button(action: processPayment) {
                    HStack {
                        Image(systemName: "lock.shield")
                        Text("pay_now".localized())
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!isFormValid || isProcessing)
            }
        }
    }
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Processing payment...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(15)
        }
    }
    
    private var isFormValid: Bool {
        !cardNumber.isEmpty &&
        cardNumber.replacingOccurrences(of: " ", with: "").count >= 16 &&
        !cardholderName.isEmpty &&
        expiryDate.count == 5 &&
        cvv.count >= 3
    }
    
    private func formatCardNumber(_ value: String) -> String {
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
    
    private func formatExpiryDate(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: "/", with: "")
        let truncated = String(cleaned.prefix(4))
        
        if truncated.count >= 3 {
            let month = String(truncated.prefix(2))
            let year = String(truncated.suffix(truncated.count - 2))
            return "\(month)/\(year)"
        }
        return truncated
    }
    
    private func processPayment() {
        print("💳 Processing payment...")
        isProcessing = true
        
        // Add the cart items to the view model
        cartViewModel.cartItems = cartItems
        cartViewModel.isGiftMode = isGift
        cartViewModel.selectedGiftRecipient = giftRecipient
        cartViewModel.giftMessage = giftMessage
        
        // Simulate payment processing
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            print("🔄 Calling checkout API...")
            
            let success = await cartViewModel.proceedToCheckout(
                userId: appState.currentUser?.id ?? 0,
                currency: appState.currentCurrency.rawValue,
                appState: appState
            )
            
            await MainActor.run {
                isProcessing = false
                if success {
                    successOrderId = cartViewModel.lastPurchaseId
                    
                    // Force update the app state to refresh purchase history
                    appState.loadCurrentUser()
                    
                    print("✅ Payment successful! Order ID: \(successOrderId ?? 0)")
                    print("📊 User now has \(appState.currentUser?.purchaseHistory.count ?? 0) purchases")
                    
                    showingSuccess = true
                } else {
                    errorMessage = isGift ? "gift_order_failed".localized() : "payment_failed".localized()
                    print("❌ Payment failed")
                    showingError = true
                }
            }
        }
    }
}
