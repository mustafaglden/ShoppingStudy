//
//  Product.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

struct Product: Decodable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
    
    struct Rating: Decodable {
        let rate: Double
        let count: Int
    }
}
