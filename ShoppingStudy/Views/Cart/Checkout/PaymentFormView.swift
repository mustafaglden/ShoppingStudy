//
//  PaymentFormView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct PaymentFormView: View {
    @Binding var cardNumber: String
    @Binding var cardholderName: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    
    let onPay: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("payment_information".localized())
                .font(.headline)
            
            VStack(spacing: 15) {
                // Card Number
                cardNumberView
                
                // Cardholder Name
                cardholderNameView
                
                // Expiry + CVV
                expiryAndCvvView
                
                // Pay Button
                Button(action: onPay) {
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
                .disabled(!isFormValid)
            }
        }
    }
    
    @ViewBuilder
    private var cardNumberView: some View {
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
    }
    
    @ViewBuilder
    private var cardholderNameView: some View {
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
    }
    
    @ViewBuilder
    private var expiryAndCvvView: some View {
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
}
