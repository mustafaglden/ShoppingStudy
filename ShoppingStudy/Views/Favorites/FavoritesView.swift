//
//  FavoritesView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var appState: AppState
    @State private var favoriteProducts: [Product] = []
    @State private var isLoading = true
    @State private var selectedProduct: Product?
    
    private let productService = ProductService()
    private let persistenceManager = UserPersistenceManager.shared
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("loading_favorites".localized())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if favoriteProducts.isEmpty {
                emptyFavoritesView
            } else {
                favoritesContent
            }
        }
        .navigationTitle("favorites".localized())
        .task {
            await loadFavoriteProducts()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await loadFavoriteProducts()
            }
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
                .environmentObject(appState)
        }
    }
    
    private var favoritesContent: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(favoriteProducts) { product in
                    FavoriteProductCard(
                        product: product,
                        onRemove: {
                            removeFavorite(product: product)
                        },
                        onAddToCart: {
                            addToCart(product: product)
                        }
                    )
                    .environmentObject(appState)
                    .onTapGesture {
                        selectedProduct = product
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await loadFavoriteProducts()
        }
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("no_favorites".localized())
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("add_products_to_favorites".localized())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: ProductListView()) {
                Text("browse_products".localized())
                    .fontWeight(.medium)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func loadFavoriteProducts() async {
        isLoading = true
        guard let userId = appState.currentUser?.id else {
            isLoading = false
            return
        }
        
        let favoriteIds = Array(appState.favoriteProductIds)
        var products: [Product] = []
        
        // Fetch each favorite product
        for productId in favoriteIds {
            do {
                let product = try await productService.fetchProductDetail(id: productId)
                products.append(product)
            } catch {
                print("Failed to load product \(productId): \(error)")
            }
        }
        
        await MainActor.run {
            self.favoriteProducts = products
            self.isLoading = false
        }
    }
    
    private func removeFavorite(product: Product) {
        guard let userId = appState.currentUser?.id else { return }
        
        _ = persistenceManager.toggleFavorite(productId: product.id, for: userId)
        appState.updateFavorites()
        
        // Remove from local array
        favoriteProducts.removeAll { $0.id == product.id }
    }
    
    private func addToCart(product: Product) {
        guard let userId = appState.currentUser?.id else { return }
        
        persistenceManager.addToCart(product: product, quantity: 1, for: userId)
        appState.updateCart()
    }
}
