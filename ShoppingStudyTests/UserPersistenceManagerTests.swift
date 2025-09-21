//
//  UserPersistenceManagerTests.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import XCTest
@testable import ShoppingStudy

final class UserPersistenceManagerTests: XCTestCase {
    var sut: UserPersistenceManager!
    
    override func setUp() {
        super.setUp()
        sut = UserPersistenceManager.shared
        // Clear UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "com.shoppingStudy.userProfiles")
        UserDefaults.standard.removeObject(forKey: "com.shoppingStudy.currentUserId")
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCreateUser() {
        // Given
        let username = "testuser"
        let email = "test@example.com"
        
        // When
        let user = sut.createUser(username: username, email: email)
        
        // Then
        XCTAssertEqual(user.username, username)
        XCTAssertEqual(user.email, email)
        XCTAssertNotNil(user.id)
        XCTAssertTrue(user.favorites.isEmpty)
        XCTAssertTrue(user.currentCart.isEmpty)
    }
    
    func testGetCurrentUser() {
        // Given
        let user = sut.createUser(username: "test", email: "test@test.com")
        sut.setCurrentUser(user.id)
        
        // When
        let currentUser = sut.getCurrentUser()
        
        // Then
        XCTAssertNotNil(currentUser)
        XCTAssertEqual(currentUser?.id, user.id)
    }
    
    func testAddToCart() {
        // Given
        let user = sut.createUser(username: "test", email: "test@test.com")
        let product = Product(
            id: 1,
            title: "Test Product",
            price: 99.99,
            description: "Test Description",
            category: "test",
            image: "test.jpg",
            rating: Product.Rating(rate: 4.5, count: 100)
        )
        
        // When
        sut.addToCart(product: product, quantity: 2, for: user.id)
        let updatedUser = sut.getUser(by: user.id)
        
        // Then
        XCTAssertEqual(updatedUser?.currentCart.count, 1)
        XCTAssertEqual(updatedUser?.currentCart.first?.quantity, 2)
        XCTAssertEqual(updatedUser?.currentCart.first?.productId, product.id)
    }
    
    func testToggleFavorite() {
        // Given
        let user = sut.createUser(username: "test", email: "test@test.com")
        let productId = 1
        
        // When - Add favorite
        let isAdded = sut.toggleFavorite(productId: productId, for: user.id)
        
        // Then
        XCTAssertTrue(isAdded)
        XCTAssertTrue(sut.isFavorite(productId: productId, for: user.id))
        
        // When - Remove favorite
        let isRemoved = sut.toggleFavorite(productId: productId, for: user.id)
        
        // Then
        XCTAssertFalse(isRemoved)
        XCTAssertFalse(sut.isFavorite(productId: productId, for: user.id))
    }
    
    func testCompletePurchase() {
        // Given
        let user = sut.createUser(username: "test", email: "test@test.com")
        let product = Product(
            id: 1,
            title: "Test Product",
            price: 50.0,
            description: "Test",
            category: "test",
            image: "test.jpg",
            rating: Product.Rating(rate: 4.0, count: 10)
        )
        let cartItem = CartItem(product: product, quantity: 2)
        
        // When
        sut.completePurchase(
            cart: [cartItem],
            orderId: 1001,
            userId: user.id,
            currency: "USD"
        )
        
        // Then
        let updatedUser = sut.getUser(by: user.id)
        XCTAssertEqual(updatedUser?.purchaseHistory.count, 1)
        XCTAssertEqual(updatedUser?.totalPurchases, 100.0) // 50 * 2
        XCTAssertEqual(updatedUser?.totalItemsPurchased, 2)
        XCTAssertTrue(updatedUser?.currentCart.isEmpty ?? false)
    }
}
