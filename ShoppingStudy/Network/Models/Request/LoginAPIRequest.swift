//
//  LoginAPIRequest.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//


import Foundation

struct LoginAPIRequest: APIRequest {
    typealias ResponseType = LoginResponse
    
    let endpoint = APIEndpoints.login.url
    let method: HTTPMethod = .post
    let body: Data?
    
    init(username: String, password: String) throws {
        let loginRequest = LoginRequestParameters(username: username, password: password)
        self.body = try JSONEncoder().encode(loginRequest)
    }
}

