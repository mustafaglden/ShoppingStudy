//
//  ExchangeRateRequest.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

struct ExchangeRateRequest: APIRequest {
    typealias ResponseType = ExchangeRateResponse
    
    let endpoint: String
    let method: HTTPMethod = .get
    
    init(baseCurrency: String) {
        self.endpoint = APIEndpoints.exchangeRates(baseCurrency).url
    }
}
