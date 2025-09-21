//
//  CartHistoryRow.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct CartHistoryRow: View {
    let cart: GetCartsResponse
    let viewModel: ProfileViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "bag.fill")
                    .foregroundColor(.blue)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("order_number".localized(with: cart.id))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("\(cart.products.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatCartDate(cart.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Price
            Text(appState.formatPrice(viewModel.calculateCartTotal(cart: cart)))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}
