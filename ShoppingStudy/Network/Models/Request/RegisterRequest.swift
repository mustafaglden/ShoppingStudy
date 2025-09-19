//
//  RegisterRequest.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}
