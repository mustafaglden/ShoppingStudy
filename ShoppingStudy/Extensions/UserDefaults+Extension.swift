//
//  UserDefaults+Extension.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//

import Foundation

extension UserDefaults {
    static let appSuite: UserDefaults = {
        guard let suite = UserDefaults(suiteName: "group.com.shoppingStudy") else {
            return UserDefaults.standard
        }
        return suite
    }()
}
