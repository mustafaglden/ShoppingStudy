//
//  GetUserCartsRequest.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

// MARK: - GetUserCartsRequest.swift
import Foundation

struct GetUserCartsRequest: APIRequest {
    typealias ResponseType = [GetCartsResponse]
    
    let endpoint: String
    let method: HTTPMethod = .get
    
    init(userId: Int) {
        self.endpoint = APIEndpoints.userCarts(userId).url
    }
}
