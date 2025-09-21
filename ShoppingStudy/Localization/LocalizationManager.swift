//
//  LocalizationManager.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI
import Combine

protocol LocalizationManagerProtocol: ObservableObject {
    var currentLanguage: Language { get set }
    var bundle: Bundle { get set }
    
    func setLanguage(_ language: Language)
    func localizedString(_ key: String) -> String
}

final class LocalizationManager: LocalizationManagerProtocol {
    @Published var currentLanguage: Language = .english
    @Published var bundle: Bundle = .main
    
    static let shared = LocalizationManager()
    
    init() {
        loadSavedLanguage()
        updateBundle()
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.appSuite.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.appSuite.synchronize()
        updateBundle()
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
        if let languageCodes = UserDefaults.appSuite.array(forKey: "AppleLanguages") as? [String],
           let firstLanguage = languageCodes.first {
            if firstLanguage.hasPrefix("tr") {
                currentLanguage = .turkish
            } else {
                currentLanguage = .english
            }
        } else {
            if let preferredLanguage = Locale.current.language.languageCode?.identifier {
                currentLanguage = preferredLanguage.hasPrefix("tr") ? .turkish : .english
            }
        }
    }
    
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
