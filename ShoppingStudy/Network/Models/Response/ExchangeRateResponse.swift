//
//  ExchangeRateResponse.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

struct ExchangeRateResponse: Codable {
    let result: String
    let base_code: String
    let conversion_rates: [String: Double]
}
