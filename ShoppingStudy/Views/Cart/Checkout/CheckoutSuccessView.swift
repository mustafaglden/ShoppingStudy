//
//  CheckoutSuccessView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import SwiftUI

struct CheckoutSuccessView: View {
    let message: String
    let orderId: Int?
    let onContinueShopping: () -> Void
    
    @State private var animateCheckmark = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.2), lineWidth: 4)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: animateCheckmark ? 1 : 0)
                    .stroke(Color.green, lineWidth: 4)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: animateCheckmark)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.green)
                    .scaleEffect(animateCheckmark ? 1 : 0.5)
                    .opacity(animateCheckmark ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateCheckmark)
            }
            
            VStack(spacing: 15) {
                Text("success".localized())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                if let orderId = orderId {
                    Text("order_number".localized(with: orderId))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                }
            }
            
            Button(action: onContinueShopping) {
                Text("continue_shopping".localized())
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .padding()
        .onAppear {
            withAnimation {
                animateCheckmark = true
            }
        }
    }
}
