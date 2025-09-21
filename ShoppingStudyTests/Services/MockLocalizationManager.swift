//
//  MockLocalizationManager.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 22.09.2025.
//


import SwiftUI
import Combine
@testable import ShoppingStudy

class MockLocalizationManager: LocalizationManagerProtocol {
    @Published var currentLanguage: Language = .english
    @Published var bundle: Bundle = .main
    
    var setLanguageCalled = false
    var localizedStringCalled = false
    
    func setLanguage(_ language: Language) {
        setLanguageCalled = true
        currentLanguage = language
    }
    
    func localizedString(_ key: String) -> String {
        localizedStringCalled = true
        return key // Return the key itself for testing
    }
}