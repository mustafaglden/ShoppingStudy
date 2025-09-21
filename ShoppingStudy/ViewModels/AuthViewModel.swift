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
    @Published var showingRegister = false
    
    private let authService: AuthServiceProtocol
    private let persistenceManager: UserPersistenceManagerProtocol
    private let localizationManager: LocalizationManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService(),
         persistenceManager: UserPersistenceManagerProtocol = UserPersistenceManager.shared,
         localizationManager: LocalizationManagerProtocol = LocalizationManager.shared) {
        self.authService = authService
        self.persistenceManager = persistenceManager
        self.localizationManager = localizationManager
        loadSavedLanguage()
    }
    
    private func loadSavedLanguage() {
        selectedLanguage = localizationManager.currentLanguage
    }
    
    func updateLanguage(_ language: Language, appState: AppStateProtocol) {
        selectedLanguage = language
        localizationManager.setLanguage(language)
        appState.currentLanguage = language
    }
    
    func showRegisterView() {
        showingRegister = true
    }
    
    func dismissRegisterView() {
        showingRegister = false
    }
    
    func dismissError() {
        showingError = false
        errorMessage = nil
    }
    
    func login(appState: AppStateProtocol) async {
        guard validateLoginFields() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.login(username: username, password: password)
            
            if let existingUser = persistenceManager.getUser(by: username, password: password) {
                await MainActor.run {
                    appState.login(user: existingUser)
                }
            } else {
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
    
    func register(appState: AppStateProtocol) async {
        guard validateRegistrationFields() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let parameters = RegisterRequestParameters(
                email: email,
                username: username,
                password: password
            )
            
            _ = try await authService.register(parameters: parameters)
            
            let newUser = persistenceManager.createUser(username: username, email: email)
            
            await MainActor.run {
                appState.login(user: newUser)
                self.dismissRegisterView()
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
