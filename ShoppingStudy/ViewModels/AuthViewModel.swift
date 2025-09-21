//
//  AuthViewModel.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    @Published var selectedLanguage: Language = .english
    
    private let authService: AuthServiceProtocol
    private let persistenceManager = UserPersistenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        loadSavedLanguage()
    }
    
    private func loadSavedLanguage() {
        if let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let firstLanguage = languageCodes.first {
            if firstLanguage.hasPrefix("tr") {
                selectedLanguage = .turkish
            } else {
                selectedLanguage = .english
            }
        }
    }
    
    func login(appState: AppState) async {
        guard validateLoginFields() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Try API login
            _ = try await authService.login(username: username, password: password)
            
            // Check if user exists locally
            if let existingUser = persistenceManager.getUser(by: username, password: password) {
                await MainActor.run {
                    appState.login(user: existingUser)
                }
            } else {
                // Create new local user profile
                let newUser = persistenceManager.createUser(username: username, email: "\(username)@example.com")
                await MainActor.run {
                    appState.login(user: newUser)
                }
            }
            
            clearFields()
        } catch {
            await MainActor.run {
                self.errorMessage = "login_failed".localized()
                self.showingError = true
            }
        }
        
        isLoading = false
    }
    
    func register(appState: AppState) async {
        guard validateRegistrationFields() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let parameters = RegisterRequestParameters(
                email: email,
                username: username,
                password: password
            )
            
            // Try API registration
            _ = try await authService.register(parameters: parameters)
            
            // Create local user profile
            let newUser = persistenceManager.createUser(username: username, email: email)
            
            await MainActor.run {
                appState.login(user: newUser)
            }
            
            clearFields()
        } catch {
            await MainActor.run {
                self.errorMessage = "registration_failed".localized()
                self.showingError = true
            }
        }
        
        isLoading = false
    }
    
    func updateLanguage(_ language: Language, appState: AppState) {
        selectedLanguage = language
        appState.currentLanguage = language
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        
        // Post notification for language change
        NotificationCenter.default.post(
            name: Notification.Name("LanguageDidChange"),
            object: nil
        )
    }
    
    private func validateLoginFields() -> Bool {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "username_password_required".localized()
            showingError = true
            return false
        }
        return true
    }
    
    private func validateRegistrationFields() -> Bool {
        guard !username.isEmpty, !password.isEmpty, !email.isEmpty else {
            errorMessage = "all_fields_required".localized()
            showingError = true
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "invalid_email".localized()
            showingError = true
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "password_too_short".localized()
            showingError = true
            return false
        }
        
        return true
    }
    
    private func clearFields() {
        username = ""
        password = ""
        email = ""
    }
}
