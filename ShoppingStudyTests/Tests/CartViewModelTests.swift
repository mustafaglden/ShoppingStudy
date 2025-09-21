//
//  CartViewModelTests.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import XCTest
@testable import ShoppingStudy

@MainActor
final class CartViewModelTests: XCTestCase {
    var sut: CartViewModel!
    var mockPersistenceManager: MockUserPersistenceManager!
    var mockCartService: MockCartService!
    var mockAppState: AppState!
    
    override func setUp() async throws {
        mockPersistenceManager = MockUserPersistenceManager()
        mockCartService = MockCartService()
        sut = CartViewModel(
            persistenceManager: mockPersistenceManager,
            cartService: mockCartService
        )
        
        // Create mock app state
        mockAppState = AppState(
            persistenceManager: mockPersistenceManager,
            currencyService: MockCurrencyService()
        )
    }
    
    func testLoadCart() {
        // Given
        let product = Product(
            id: 1,
            title: "Test",
            price: 10.0,
            description: "Test",
            category: "test",
            image: "test.jpg",
            rating: Product.Rating(rate: 4.0, count: 10)
        )
        var user = UserProfile(id: 1, username: "test", email: "test@test.com")
        user.currentCart = [CartItem(product: product, quantity: 2)]
        mockPersistenceManager.users = [user]
        mockPersistenceManager.mockUser = user
        
        // When
        sut.loadCart(userId: 1)
        
        // Then
        XCTAssertEqual(sut.cartItems.count, 1)
        XCTAssertEqual(sut.cartItems[0].quantity, 2)
        XCTAssertEqual(sut.totalPrice, 20.0)
    }
    
    func testToggleGiftMode() {
        // When - Enable gift mode
        sut.toggleGiftMode()
        
        // Then
        XCTAssertTrue(sut.isGiftMode)
        XCTAssertTrue(sut.showingGiftSelector)
        
        // When - Disable gift mode
        sut.toggleGiftMode()
        
        // Then
        XCTAssertFalse(sut.isGiftMode)
        XCTAssertNil(sut.selectedGiftRecipient)
        XCTAssertEqual(sut.giftMessage, "")
    }
    
    func testProceedToCheckoutSuccess() async {
        // Given
        let product = Product(
            id: 1,
            title: "Test",
            price: 10.0,
            description: "Test",
            category: "test",
            image: "test.jpg",
            rating: Product.Rating(rate: 4.0, count: 10)
        )
        let cartItem = CartItem(product: product, quantity: 1)
        sut.cartItems = [cartItem]
        
        let user = UserProfile(id: 1, username: "test", email: "test@test.com")
        mockAppState.currentUser = user
        mockPersistenceManager.users = [user]
        
        mockCartService.mockResponse = AddCartResponse(
            id: 123,
            userId: 1,
            date: "2025-01-01",
            products: []
        )
        
        // When
        let success = await sut.proceedToCheckout(
            userId: 1,
            currency: "USD",
            appState: mockAppState
        )
        
        // Then
        XCTAssertTrue(success)
        XCTAssertTrue(mockCartService.addCartCalled)
        XCTAssertTrue(mockPersistenceManager.completePurchaseCalled)
        XCTAssertEqual(sut.lastPurchaseId, 123)
        XCTAssertTrue(sut.checkoutCompleted)
        XCTAssertTrue(sut.showingSuccess)
        XCTAssertFalse(sut.successMessage.isEmpty)
        XCTAssertEqual(sut.cartItems.count, 0) // Cart should be cleared
    }
}
