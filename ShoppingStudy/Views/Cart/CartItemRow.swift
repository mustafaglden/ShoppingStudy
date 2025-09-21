//
//  CartItemRow.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct CartItemRow: View {
    let item: CartItem
    let onUpdateQuantity: (Int) -> Void
    let onDelete: () -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            AsyncImage(url: URL(string: item.product.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure(_), .empty:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                @unknown default:
                    ProgressView()
                }
            }
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("unit_price".localized(with: appState.formatPrice(item.product.price)))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Quantity Controls
                HStack(spacing: 15) {
                    Button(action: {
                        if item.quantity > 1 {
                            onUpdateQuantity(item.quantity - 1)
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(item.quantity > 1 ? .blue : .gray)
                    }
                    .disabled(item.quantity <= 1)
                    
                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(minWidth: 30)
                    
                    Button(action: {
                        onUpdateQuantity(item.quantity + 1)
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Price and Delete
            VStack(alignment: .trailing, spacing: 8) {
                Text(appState.formatPrice(item.totalPrice))
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}
