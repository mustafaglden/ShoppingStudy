//
//  LocalizationManager.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

final class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language = .english
    
    static let shared = LocalizationManager()
    
    private init() {
        loadSavedLanguage()
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(
            name: Notification.Name("LanguageDidChange"),
            object: nil
        )
    }
    
    private func loadSavedLanguage() {
        if let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let firstLanguage = languageCodes.first {
            if firstLanguage.hasPrefix("tr") {
                currentLanguage = .turkish
            } else {
                currentLanguage = .english
            }
        }
    }
}
