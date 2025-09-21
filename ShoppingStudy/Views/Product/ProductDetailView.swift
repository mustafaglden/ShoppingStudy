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
    @StateObject private var viewModel = ProductDetailViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    productImage
                    productInfoSection
                }
            }
            .navigationTitle("product_details".localized())
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
                viewModel.checkIfFavorite(
                    productId: product.id,
                    userId: appState.currentUser?.id ?? 0
                )
            }
        }
    }
    
    private var productImage: some View {
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
    }
    
    private var productInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            titleAndCategory
            ratingSection
            Divider()
            priceSection
            quantitySection
            Divider()
            descriptionSection
            actionButtons
        }
        .padding()
    }
    
    private var titleAndCategory: some View {
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
    }
    
    private var ratingSection: some View {
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
    }
    
    private var priceSection: some View {
        HStack {
            Text("price".localized())
                .font(.headline)
            Spacer()
            Text(appState.formatPrice(product.price))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
    }
    
    private var quantitySection: some View {
        HStack {
            Text("quantity".localized())
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: viewModel.decreaseQuantity) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.quantity > 1 ? .blue : .gray)
                }
                .disabled(viewModel.quantity <= 1)
                
                Text("\(viewModel.quantity)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 40)
                
                Button(action: viewModel.increaseQuantity) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("description".localized())
                .font(.headline)
            
            Text(product.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.addToCart(
                    product: product,
                    userId: appState.currentUser?.id ?? 0,
                    appState: appState,
                    onComplete: { dismiss() }
                )
            }) {
                HStack {
                    Image(systemName: viewModel.showingAddedToCart ? "checkmark.circle.fill" : "cart.badge.plus")
                    Text(viewModel.showingAddedToCart ? "added_to_cart".localized() : "add_to_cart".localized())
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(viewModel.showingAddedToCart ? Color.green : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.showingAddedToCart)
            
            Button(action: {
                viewModel.toggleFavorite(
                    productId: product.id,
                    userId: appState.currentUser?.id ?? 0,
                    appState: appState
                )
            }) {
                HStack {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    Text(viewModel.isFavorite ? "remove_from_favorites".localized() : "add_to_favorites".localized())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(viewModel.isFavorite ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                .foregroundColor(viewModel.isFavorite ? .red : .primary)
                .cornerRadius(10)
            }
        }
    }
}
