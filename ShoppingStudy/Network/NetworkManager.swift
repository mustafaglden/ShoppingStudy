//
//  NetworkManager.swift
//  ShoppingSpree
//
//  Created by Mustafa Gülden on 18.09.2025.
//

import Foundation

protocol NetworkManager: AnyObject {
    func makeRequest<T: APIRequest>(_ request: T) async throws -> T.ResponseType
}
