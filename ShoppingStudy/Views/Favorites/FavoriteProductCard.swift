//
//  FavoriteProductCard.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct FavoriteProductCard: View {
    let product: Product
    let onRemove: () -> Void
    let onAddToCart: () -> Void
    @EnvironmentObject var appState: AppState
    @State private var showingRemoveAlert = false
    @State private var showingAddedToCart = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Product Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                    case .failure(_):
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                    @unknown default:
                        EmptyView()
                    }
                }
                .background(Color.gray.opacity(0.1))
                
                // Remove Button
                Button(action: {
                    showingRemoveAlert = true
                }) {
                    Image(systemName: "heart.slash.fill")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Rating
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", product.rating.rate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Price
                Text(appState.formatPrice(product.price))
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // Add to Cart Button
                Button(action: {
                    onAddToCart()
                    withAnimation {
                        showingAddedToCart = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingAddedToCart = false
                    }
                }) {
                    HStack {
                        Image(systemName: showingAddedToCart ? "checkmark" : "cart.badge.plus")
                        Text(showingAddedToCart ? "added_to_cart".localized() : "add_to_cart".localized())
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(showingAddedToCart ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(showingAddedToCart)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .alert("remove_from_favorites".localized(), isPresented: $showingRemoveAlert) {
            Button("cancel".localized(), role: .cancel) {}
            Button("remove".localized(), role: .destructive) {
                onRemove()
            }
        } message: {
            Text("confirm_remove_from_favorites".localized())
        }
    }
}
