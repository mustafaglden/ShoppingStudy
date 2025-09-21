//
//  String+Extension.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import Foundation

extension String {
    func localized() -> String {
        return LocalizationManager.shared.localizedString(self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let format = LocalizationManager.shared.localizedString(self)
        return String(format: format, arguments: arguments)
    }
}
