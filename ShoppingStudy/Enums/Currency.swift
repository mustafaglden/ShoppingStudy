//
//  Currency.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

enum Currency: String, CaseIterable {
    case usd = "USD"
    case eur = "EUR"
    case try_ = "TRY"
    
    var displayName: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .try_: return "Turkish Lira"
        }
    }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .try_: return "₺"
        }
    }
}
