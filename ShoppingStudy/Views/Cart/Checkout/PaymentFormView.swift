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
    
    let isFormValid: Bool
    let onPay: () -> Void
    let formatCardNumber: (String) -> String
    let formatExpiryDate: (String) -> String
    let limitCVV: (String) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("payment_information".localized())
                .font(.headline)
            
            VStack(spacing: 15) {
                cardNumberField
                cardholderNameField
                expiryAndCvvFields
                payButton
            }
        }
    }
    
    private var cardNumberField: some View {
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
    
    private var cardholderNameField: some View {
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
    
    private var expiryAndCvvFields: some View {
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
                            cvv = limitCVV(newValue)
                        }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var payButton: some View {
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
