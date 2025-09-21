//
//  ProfileViewModel.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var userCarts: [GetCartsResponse] = []
    @Published var isLoadingCarts = false
    @Published var cartProducts: [Int: Product] = [:]
    @Published var errorMessage: String?
    @Published var showingError = false
    @Published var showingSettings = false
    @Published var showingLogoutAlert = false
    @Published var selectedCart: GetCartsResponse?
    
    private let cartService: CartServiceProtocol
    private let productService: ProductServiceProtocol
    
    init(cartService: CartServiceProtocol = CartService(),
         productService: ProductServiceProtocol = ProductService()) {
        self.cartService = cartService
        self.productService = productService
    }
    
    func showSettings() {
        showingSettings = true
    }
    
    func dismissSettings() {
        showingSettings = false
    }
    
    func confirmLogout() {
        showingLogoutAlert = true
    }
    
    func performLogout(appState: AppStateProtocol) {
        appState.logout()
        showingLogoutAlert = false
    }
    
    func selectCart(_ cart: GetCartsResponse) {
        selectedCart = cart
    }
    
    func dismissCartDetail() {
        selectedCart = nil
    }
    
    func loadUserCarts(userId: Int) async {
        isLoadingCarts = true
        errorMessage = nil
        
        do {
            let carts = try await cartService.getUserCarts(userId: userId)
            
            // Sort by date (newest first)
            let sortedCarts = carts.sorted { cart1, cart2 in
                guard let date1 = ISO8601DateFormatter().date(from: cart1.date),
                      let date2 = ISO8601DateFormatter().date(from: cart2.date) else {
                    return false
                }
                return date1 > date2
            }
            
            await MainActor.run {
                self.userCarts = sortedCarts
                self.isLoadingCarts = false
            }
            
            await loadProductsForCarts(sortedCarts)
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showingError = true
                self.isLoadingCarts = false
            }
        }
    }
    
    private func loadProductsForCarts(_ carts: [GetCartsResponse]) async {
        var productIds = Set<Int>()
        for cart in carts {
            for product in cart.products {
                productIds.insert(product.productId)
            }
        }
        
        for productId in productIds {
            do {
                let product = try await productService.fetchProductDetail(id: productId)
                await MainActor.run {
                    self.cartProducts[productId] = product
                }
            } catch {
                print("Failed to load product \(productId): \(error)")
            }
        }
    }
    
    func getProduct(for productId: Int) -> Product? {
        return cartProducts[productId]
    }
    
    func calculateCartTotal(cart: GetCartsResponse) -> Double {
        var total: Double = 0
        for cartProduct in cart.products {
            if let product = cartProducts[cartProduct.productId] {
                total += product.price * Double(cartProduct.quantity)
            }
        }
        return total
    }
    
    func calculateTotalPurchases(localTotal: Double) -> Double {
        var total = localTotal
        for cart in userCarts {
            total += calculateCartTotal(cart: cart)
        }
        return total
    }
    
    func formatCartDate(_ dateString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            return dateString
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
