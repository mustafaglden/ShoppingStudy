//
//  ProcessingPaymentView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import SwiftUI

struct ProcessingPaymentView: View {
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 30) {
            // Animated Loading Circle
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(animationAmount * 360))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            animationAmount = 2
                        }
                    }
            }
            
            VStack(spacing: 10) {
                Text("processing_payment".localized())
                    .font(.headline)
                
                Text("Please wait...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
