//
//  IntegrationTests.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import XCTest
@testable import ShoppingStudy

@MainActor
final class IntegrationTests: XCTestCase {
    
    func testCompleteCheckoutFlow() async {
        // Setup
        let persistenceManager = MockUserPersistenceManager()
        let currencyService = MockCurrencyService()
        let cartService = MockCartService()
        
        let appState = AppState(
            persistenceManager: persistenceManager,
            currencyService: currencyService
        )
        
        let cartViewModel = CartViewModel(
            persistenceManager: persistenceManager,
            cartService: cartService
        )
        
        // Create user and login
        let user = UserProfile(id: 1, username: "testuser", email: "test@test.com")
        persistenceManager.users = [user]
        appState.login(user: user)
        
        // Add items to cart
        let product = Product(
            id: 1,
            title: "Test Product",
            price: 50.0,
            description: "Test",
            category: "test",
            image: "test.jpg",
            rating: Product.Rating(rate: 4.0, count: 10)
        )
        
        persistenceManager.addToCart(product: product, quantity: 2, for: user.id)
        cartViewModel.loadCart(userId: user.id)
        
        // Setup mock response
        cartService.mockResponse = AddCartResponse(
            id: 999,
            userId: user.id,
            date: ISO8601DateFormatter().string(from: Date()),
            products: []
        )
        
        // Proceed to checkout
        let success = await cartViewModel.proceedToCheckout(
            userId: user.id,
            currency: "USD",
            appState: appState
        )
        
        // Verify
        XCTAssertTrue(success)
        XCTAssertTrue(cartViewModel.checkoutCompleted)
        XCTAssertTrue(cartViewModel.showingSuccess)
        XCTAssertEqual(cartViewModel.lastPurchaseId, 999)
        XCTAssertEqual(appState.cartItemCount, 0) // Cart should be cleared
        XCTAssertTrue(persistenceManager.completePurchaseCalled)
    }
}
