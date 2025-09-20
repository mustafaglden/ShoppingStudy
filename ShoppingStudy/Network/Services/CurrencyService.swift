//
//  CurrencyService.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

protocol CurrencyServiceProtocol {
    func getExchangeRates(for baseCurrency: String) async throws -> [String: Double]
    func convertPrice(_ price: Double, from: String, to: String, rates: [String: Double]) -> Double
}

final class CurrencyService: CurrencyServiceProtocol {
    private let networkManager: NetworkManager
    private var cachedRates: [String: Double] = [:]
    private var lastFetchTime: Date?
    
    init(networkManager: NetworkManager = NetworkService.shared) {
        self.networkManager = networkManager
    }
    
    func getExchangeRates(for baseCurrency: String) async throws -> [String: Double] {
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < 3600,
           !cachedRates.isEmpty {
            return cachedRates
        }
        
        let request = ExchangeRateRequest(baseCurrency: baseCurrency)
        let response = try await networkManager.makeRequest(request)
        
        cachedRates = response.conversion_rates
        lastFetchTime = Date()
        
        return cachedRates
    }
    
    // BURADA Currency Enumı kullan.
    func convertPrice(_ price: Double, from: String, to: String, rates: [String: Double]) -> Double {
        if from == to { return price }
        
        guard let toRate = rates[to] else { return price }
        
        if from == "USD" {
            return price * toRate
        } else if to == "USD" {
            guard let fromRate = rates[from] else { return price }
            return price / fromRate
        } else {
            guard let fromRate = rates[from] else { return price }
            let usdPrice = price / fromRate
            return usdPrice * toRate
        }
    }
}
