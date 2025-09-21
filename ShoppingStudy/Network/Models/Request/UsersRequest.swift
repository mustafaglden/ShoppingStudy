//
//  UsersRequest.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import Foundation

struct UsersRequest: APIRequest {
    typealias ResponseType = [User]
    let endpoint = APIEndpoints.users.url
    let method: HTTPMethod = .get
}
