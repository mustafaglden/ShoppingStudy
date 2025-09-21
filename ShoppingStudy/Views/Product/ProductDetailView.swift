//
//  ProductDetailView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var quantity = 1
    @State private var showingAddedToCart = false
    @State private var isFavorite = false
    
    private let persistenceManager = UserPersistenceManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Product Image
                    AsyncImage(url: URL(string: product.image)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                                .frame(maxWidth: .infinity)
                        case .failure(_):
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Product Info
                    VStack(alignment: .leading, spacing: 15) {
                        // Title and Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(product.category.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Rating
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(product.rating.rate) ? "star.fill" : "star")
                                    .foregroundColor(.orange)
                                    .font(.subheadline)
                            }
                            Text("rating_with_count".localized(with: product.rating.rate, product.rating.count))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Price
                        HStack {
                            Text("price".localized())
                                .font(.headline)
                            Spacer()
                            Text(appState.formatPrice(product.price))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        // Quantity Selector
                        HStack {
                            Text("quantity".localized())
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    if quantity > 1 { quantity -= 1 }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(quantity > 1 ? .blue : .gray)
                                }
                                .disabled(quantity <= 1)
                                
                                Text("\(quantity)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 40)
                                
                                Button(action: {
                                    quantity += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("description".localized())
                                .font(.headline)
                            
                            Text(product.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Add to Cart Button
                            Button(action: addToCart) {
                                HStack {
                                    Image(systemName: showingAddedToCart ? "checkmark.circle.fill" : "cart.badge.plus")
                                    Text(showingAddedToCart ? "added_to_cart".localized() : "add_to_cart".localized())
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(showingAddedToCart ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(showingAddedToCart)
                            
                            // Favorite Button
                            Button(action: toggleFavorite) {
                                HStack {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    Text(isFavorite ? "remove_from_favorites".localized() : "Add to Favorites")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(isFavorite ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                                .foregroundColor(isFavorite ? .red : .primary)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Product Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                checkIfFavorite()
            }
        }
    }
    
    private func addToCart() {
        guard let userId = appState.currentUser?.id else { return }
        
        persistenceManager.addToCart(
            product: product,
            quantity: quantity,
            for: userId
        )
        appState.updateCart()
        
        withAnimation {
            showingAddedToCart = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingAddedToCart = false
            dismiss()
        }
    }
    
    private func toggleFavorite() {
        guard let userId = appState.currentUser?.id else { return }
        
        isFavorite = persistenceManager.toggleFavorite(
            productId: product.id,
            for: userId
        )
        appState.updateFavorites()
    }
    
    private func checkIfFavorite() {
        guard let userId = appState.currentUser?.id else { return }
        isFavorite = persistenceManager.isFavorite(
            productId: product.id,
            for: userId
        )
    }
}
