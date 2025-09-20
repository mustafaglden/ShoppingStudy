//
//  RegisterAPIRequest.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

struct RegisterAPIRequest: APIRequest {
    typealias ResponseType = RegisterResponse
    
    let endpoint = APIEndpoints.users.url
    let method: HTTPMethod = .post
    let body: Data?
    
    init(parameters: RegisterRequestParameters) throws {
        self.body = try JSONEncoder().encode(parameters)
    }
}
