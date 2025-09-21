//
//  CurrencyServiceTests.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import XCTest
@testable import ShoppingStudy

final class CurrencyServiceTests: XCTestCase {
    var sut: CurrencyService!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        sut = CurrencyService(networkManager: mockNetworkManager)
    }
    
    func testConvertPriceUSDToEUR() {
        // Given
        let rates = ["EUR": 0.85, "TRY": 32.5]
        let priceInUSD = 100.0
        
        // When
        let priceInEUR = sut.convertPrice(priceInUSD, from: "USD", to: "EUR", rates: rates)
        
        // Then
        XCTAssertEqual(priceInEUR, 85.0)
    }
    
    func testConvertPriceSameCurrency() {
        // Given
        let rates = ["EUR": 0.85, "TRY": 32.5]
        let price = 100.0
        
        // When
        let convertedPrice = sut.convertPrice(price, from: "USD", to: "USD", rates: rates)
        
        // Then
        XCTAssertEqual(convertedPrice, price)
    }
    
    func testConvertPriceInvalidCurrency() {
        // Given
        let rates = ["EUR": 0.85]
        let price = 100.0
        
        // When
        let convertedPrice = sut.convertPrice(price, from: "USD", to: "GBP", rates: rates)
        
        // Then
        XCTAssertEqual(convertedPrice, price) // Should return original price if rate not found
    }
}
