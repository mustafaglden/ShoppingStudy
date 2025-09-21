//
//  ProductDetailViewModel.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import SwiftUI

@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published var quantity = 1
    @Published var showingAddedToCart = false
    @Published var isFavorite = false
    
    private let persistenceManager: UserPersistenceManagerProtocol
    
    init(persistenceManager: UserPersistenceManagerProtocol = UserPersistenceManager.shared) {
        self.persistenceManager = persistenceManager
    }
    
    func increaseQuantity() {
        quantity += 1
    }
    
    func decreaseQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
    
    func checkIfFavorite(productId: Int, userId: Int) {
        isFavorite = persistenceManager.isFavorite(productId: productId, for: userId)
    }
    
    func addToCart(product: Product, userId: Int, appState: AppStateProtocol, onComplete: @escaping () -> Void) {
        persistenceManager.addToCart(
            product: product,
            quantity: quantity,
            for: userId
        )
        appState.updateCart()
        
        withAnimation {
            showingAddedToCart = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showingAddedToCart = false
            onComplete()
        }
    }
    
    func toggleFavorite(productId: Int, userId: Int, appState: AppStateProtocol) {
        isFavorite = persistenceManager.toggleFavorite(
            productId: productId,
            for: userId
        )
        appState.updateFavorites()
    }
}
