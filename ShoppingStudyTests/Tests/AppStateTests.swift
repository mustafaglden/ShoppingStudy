//
//  AppStateTests.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import XCTest
@testable import ShoppingStudy

@MainActor
final class AppStateTests: XCTestCase {
    var sut: AppState!
    var mockPersistenceManager: MockUserPersistenceManager!
    var mockCurrencyService: MockCurrencyService!
    
    override func setUp() async throws {
        mockPersistenceManager = MockUserPersistenceManager()
        mockCurrencyService = MockCurrencyService()
        sut = AppState(
            persistenceManager: mockPersistenceManager,
            currencyService: mockCurrencyService
        )
    }
    
    func testInitialState() {
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertEqual(sut.cartItemCount, 0)
        XCTAssertEqual(sut.totalAmountSpent, 0)
        XCTAssertTrue(sut.favoriteProductIds.isEmpty)
    }
    
    func testLoginUpdatesState() {
        // Given
        let user = UserProfile(id: 1, username: "testuser", email: "test@test.com")
        mockPersistenceManager.users = [user]
        
        // When
        sut.login(user: user)
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(sut.currentUser?.id, user.id)
        XCTAssertEqual(sut.currentUser?.username, "testuser")
        XCTAssertEqual(sut.cartItemCount, 0)
        XCTAssertTrue(mockPersistenceManager.setCurrentUserCalled)
    }
    
    func testLogoutClearsState() {
        // Given
        let user = UserProfile(id: 1, username: "test", email: "test@test.com")
        mockPersistenceManager.users = [user]
        sut.login(user: user)
        
        // When
        sut.logout()
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertEqual(sut.cartItemCount, 0)
        XCTAssertEqual(sut.totalAmountSpent, 0)
        XCTAssertTrue(mockPersistenceManager.logoutCalled)
    }
    
    func testUpdateCartRefreshesData() {
        // Given
        var user = UserProfile(id: 1, username: "test", email: "test@test.com")
        let product = Product(
            id: 1,
            title: "Test Product",
            price: 10.0,
            description: "Test",
            category: "test",
            image: "test.jpg",
            rating: Product.Rating(rate: 4.0, count: 10)
        )
        let cartItem = CartItem(product: product, quantity: 2)
        user.currentCart = [cartItem]
        
        mockPersistenceManager.users = [user]
        mockPersistenceManager.mockUser = user
        sut.currentUser = user
        
        // When
        sut.updateCart()
        
        // Then
        XCTAssertTrue(mockPersistenceManager.getUserCalled)
        XCTAssertEqual(sut.cartItemCount, 1)
    }
    
    func testFormatPrice() {
        // Given
        sut.currentCurrency = .usd
        sut.exchangeRates = ["EUR": 0.85, "TRY": 32.5]
        
        // When
        let formatted = sut.formatPrice(100.0)
        
        // Then
        XCTAssertEqual(formatted, "$100.00")
    }
    
    func testConvertPriceWithRates() {
        // Given
        sut.currentCurrency = .eur
        sut.exchangeRates = ["EUR": 0.85, "TRY": 32.5]
        
        // When
        let converted = sut.convertPrice(100.0)
        
        // Then
        XCTAssertEqual(converted, 85.0)
    }
}
