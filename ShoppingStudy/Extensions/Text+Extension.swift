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
        self.init(NSLocalizedString(localizedKey, comment: ""))
    }
    
    init(localizedKey: String, arguments: CVarArg...) {
        let format = NSLocalizedString(localizedKey, comment: "")
        self.init(String(format: format, arguments: arguments))
    }
}
