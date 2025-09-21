//
//  SortOption.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

enum SortOption: String, CaseIterable {
    case none = "original"
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case rating = "rating"
    
    var displayName: String {
        switch self {
        case .none: return "Original"
        case .priceAsc: return "Price: Low to High"
        case .priceDesc: return "Price: High to Low"
        case .rating: return "Rating: High to Low"
        }
    }
}
