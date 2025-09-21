//
//  Text+Extension.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

// SwiftUI Text extension for localization
extension Text {
    init(localizedKey: String) {
        let localizedString = LocalizationManager.shared.localizedString(localizedKey)
        self.init(localizedString)
    }
    
    init(localizedKey: String, arguments: CVarArg...) {
        let format = LocalizationManager.shared.localizedString(localizedKey)
        let localizedString = String(format: format, arguments: arguments)
        self.init(localizedString)
    }
}
