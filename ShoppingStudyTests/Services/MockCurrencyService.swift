//
//  MockCurrencyService.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import Foundation
@testable import ShoppingStudy

class MockCurrencyService: CurrencyServiceProtocol {
    var mockRates: [String: Double] = ["EUR": 0.85, "TRY": 32.5]
    var shouldFail = false
    var getExchangeRatesCalled = false
    
    func getExchangeRates(for baseCurrency: String) async throws -> [String: Double] {
        getExchangeRatesCalled = true
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "Test", code: -1))
        }
        return mockRates
    }
    
    func convertPrice(_ price: Double, from: String, to: String, rates: [String: Double]) -> Double {
        if from == to { return price }
        guard let toRate = rates[to] else { return price }
        if from == "USD" {
            return price * toRate
        }
        return price
    }
}
