//
//  FavoritesViewModel.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favoriteProducts: [Product] = []
    @Published var isLoading = true
    @Published var selectedProduct: Product?
    @Published var showingProductDetail = false
    @Published var showingRemoveAlert = false
    @Published var productToRemove: Product?
    
    private let productService: ProductServiceProtocol
    private let persistenceManager: UserPersistenceManagerProtocol
    
    init(productService: ProductServiceProtocol = ProductService(),
         persistenceManager: UserPersistenceManagerProtocol = UserPersistenceManager.shared) {
        self.productService = productService
        self.persistenceManager = persistenceManager
    }
    
    func loadFavoriteProducts(favoriteIds: Set<Int>) async {
        isLoading = true
        let ids = Array(favoriteIds)
        var products: [Product] = []
        
        for productId in ids {
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
    
    func selectProduct(_ product: Product) {
        selectedProduct = product
        showingProductDetail = true
    }
    
    func dismissProductDetail() {
        selectedProduct = nil
        showingProductDetail = false
    }
    
    func prepareToRemoveFavorite(_ product: Product) {
        productToRemove = product
        showingRemoveAlert = true
    }
    
    func confirmRemoveFavorite(userId: Int, appState: AppStateProtocol) {
        guard let product = productToRemove else { return }
        
        _ = persistenceManager.toggleFavorite(productId: product.id, for: userId)
        appState.updateFavorites()
        
        favoriteProducts.removeAll { $0.id == product.id }
        
        productToRemove = nil
        showingRemoveAlert = false
    }
    
    func cancelRemoveFavorite() {
        productToRemove = nil
        showingRemoveAlert = false
    }
    
    func addToCart(product: Product, userId: Int, appState: AppStateProtocol) {
        persistenceManager.addToCart(product: product, quantity: 1, for: userId)
        appState.updateCart()
    }
}
