//
//  User.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 19.09.2025.
//


struct User: Codable, Identifiable, Equatable {
    let id: Int
    var email: String
    var username: String
    var password: String?
    
    var displayName: String {
        return username
    }
    
    // MARK: - Equatable
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.email == rhs.email &&
               lhs.username == rhs.username
    }
}
