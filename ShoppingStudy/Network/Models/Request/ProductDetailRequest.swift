//
//  ProductDetailRequest.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

struct ProductDetailRequest: APIRequest {
    typealias ResponseType = Product
    
    var endpoint: String
    var method: HTTPMethod = .get
    
    init(id: Int) {
        self.endpoint = APIEndpoints.product(id).url
    }
}
