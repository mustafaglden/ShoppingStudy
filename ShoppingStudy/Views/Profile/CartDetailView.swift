//
//  CartDetailView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct CartDetailView: View {
    let cart: GetCartsResponse
    let viewModel: ProfileViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Order Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("order_number".localized(with: cart.id))
                            .font(.headline)
                        
                        if let date = ISO8601DateFormatter().date(from: cart.date) {
                            Text(date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Items")
                            .font(.headline)
                        
                        ForEach(cart.products, id: \.productId) { cartProduct in
                            if let product = viewModel.getProduct(for: cartProduct.productId) {
                                HStack {
                                    AsyncImage(url: URL(string: product.image)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        default:
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .frame(width: 50, height: 50)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.title)
                                            .font(.subheadline)
                                            .lineLimit(2)
                                        
                                        Text("qty".localized(with: cartProduct.quantity))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(appState.formatPrice(product.price * Double(cartProduct.quantity)))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .padding(.vertical, 4)
                            } else {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                    Text("Loading product \(cartProduct.productId)...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Total
                    HStack {
                        Text("total".localized())
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(appState.formatPrice(viewModel.calculateCartTotal(cart: cart)))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
}
