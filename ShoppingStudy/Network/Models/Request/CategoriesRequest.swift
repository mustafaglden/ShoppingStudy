//
//  CategoriesRequest.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 19.09.2025.
//

struct CategoriesRequest: APIRequest {
    typealias ResponseType = [String]
    let endpoint = APIEndpoints.categories.url
    let method: HTTPMethod = .get
}
        
