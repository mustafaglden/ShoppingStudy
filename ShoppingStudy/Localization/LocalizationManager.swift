//
//  LocalizationManager.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI
import Combine

final class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language = .english
    @Published var bundle: Bundle = .main
    
    static let shared = LocalizationManager()
    
    private init() {
        loadSavedLanguage()
        updateBundle()
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        updateBundle()
        
        // Force UI update
        NotificationCenter.default.post(
            name: Notification.Name("LanguageDidChange"),
            object: nil
        )
    }
    
    private func updateBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            self.bundle = Bundle.main
            return
        }
        self.bundle = bundle
    }
    
    private func loadSavedLanguage() {
        if let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let firstLanguage = languageCodes.first {
            if firstLanguage.hasPrefix("tr") {
                currentLanguage = .turkish
            } else {
                currentLanguage = .english
            }
        } else {
            // Default to device language or English
            if let preferredLanguage = Locale.current.language.languageCode?.identifier {
                currentLanguage = preferredLanguage.hasPrefix("tr") ? .turkish : .english
            }
        }
    }
    
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
