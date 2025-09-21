//
//  SingleUserRequest.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import Foundation

struct SingleUserRequest: APIRequest {
    typealias ResponseType = User
    
    let endpoint: String
    let method: HTTPMethod = .get
    
    init(userId: Int) {
        self.endpoint = APIEndpoints.user(userId).url
    }
}
