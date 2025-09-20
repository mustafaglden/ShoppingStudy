//
//  RegisterResponse.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 19.09.2025.
//

struct RegisterResponse: Decodable {
    let id: Int?
    let username: String?
    let email: String?
    let password: String?  
}
