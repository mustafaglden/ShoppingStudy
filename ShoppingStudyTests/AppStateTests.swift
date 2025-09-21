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
    
    override func setUp() async throws {
        sut = AppState()
    }
    
    func testLoginUpdatesState() {
        // Given
        let user = UserProfile(id: 1, username: "test", email: "test@test.com")
        
        // When
        sut.login(user: user)
        
        // Then
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(sut.currentUser?.id, user.id)
        XCTAssertEqual(sut.cartItemCount, 0)
    }
    
    func testLogoutClearsState() {
        // Given
        let user = UserProfile(id: 1, username: "test", email: "test@test.com")
        sut.login(user: user)
        
        // When
        sut.logout()
        
        // Then
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.currentUser)
        XCTAssertEqual(sut.cartItemCount, 0)
        XCTAssertEqual(sut.totalAmountSpent, 0)
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
