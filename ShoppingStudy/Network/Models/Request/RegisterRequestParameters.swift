//
//  RegisterRequestParameters.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

struct RegisterRequestParameters: Encodable {
    let email: String
    let username: String
    let password: String
}
