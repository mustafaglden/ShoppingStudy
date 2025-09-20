//
//  ProductListRequest.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

struct ProductListRequest: APIRequest {
    typealias ResponseType = [Product]
    
    var endpoint: String
    
    var method: HTTPMethod = .get
    
    init(limit: Int? = nil, sort: String? = nil, category: String? = nil) {
        var url = APIEndpoints.products.url
        var queryItems: [String] = []
        
        if let limit = limit {
            queryItems.append("limit=\(limit)")
        }
        
        if let sort = sort {
            queryItems.append("sort=\(sort)")
        }
        
        if let category = category {
            url = APIEndpoints.category(category).url
        }
        
        if !queryItems.isEmpty {
            url += "?" + queryItems.joined(separator: "&")
        }
        
        self.endpoint = url
    }
}
