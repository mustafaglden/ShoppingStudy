//
//  OrderSummaryView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct OrderSummaryView: View {
    let cartItems: [CartItem]
    let totalAmount: Double
    let appState: AppState
    
    var body: some View {
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
}
