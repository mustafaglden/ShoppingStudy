//
//  AppState.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false
    @Published var currentLanguage: Language = .english
    @Published var currentCurrency: Currency = .usd
    @Published var exchangeRates: [String: Double] = [:]
    @Published var cartItemCount: Int = 0
    @Published var favoriteProductIds: Set<Int> = []
    
    private let persistenceManager = UserPersistenceManager.shared
    private let currencyService = CurrencyService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCurrentUser()
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe language changes
        $currentLanguage
            .sink { [weak self] language in
                self?.updateLanguage(language)
            }
            .store(in: &cancellables)
        
        // Observe currency changes
        $currentCurrency
            .sink { [weak self] currency in
                Task {
                    await self?.loadExchangeRates(for: currency)
                }
            }
            .store(in: &cancellables)
    }
    
    func loadCurrentUser() {
        if let user = persistenceManager.getCurrentUser() {
            self.currentUser = user
            self.isAuthenticated = true
            self.cartItemCount = user.currentCart.count
            self.favoriteProductIds = user.favorites
            
            // Load user preferences
            if let currency = Currency(rawValue: user.preferredCurrency) {
                self.currentCurrency = currency
            }
            if let language = Language(rawValue: user.preferredLanguage) {
                self.currentLanguage = language
            }
        }
    }
    
    func login(user: UserProfile) {
        persistenceManager.setCurrentUser(user.id)
        self.currentUser = user
        self.isAuthenticated = true
        self.cartItemCount = user.currentCart.count
        self.favoriteProductIds = user.favorites
        loadUserPreferences()
    }
    
    func logout() {
        persistenceManager.logout()
        self.currentUser = nil
        self.isAuthenticated = false
        self.cartItemCount = 0
        self.favoriteProductIds = []
    }
    
    func updateCart() {
        if let userId = currentUser?.id,
           let user = persistenceManager.getUser(by: userId) {
            self.currentUser = user
            self.cartItemCount = user.currentCart.count
        }
    }
    
    func updateFavorites() {
        if let userId = currentUser?.id,
           let user = persistenceManager.getUser(by: userId) {
            self.currentUser = user
            self.favoriteProductIds = user.favorites
        }
    }
    
    private func loadUserPreferences() {
        guard let user = currentUser else { return }
        
        if let currency = Currency(rawValue: user.preferredCurrency) {
            self.currentCurrency = currency
        }
        
        if let language = Language(rawValue: user.preferredLanguage) {
            self.currentLanguage = language
        }
    }
    
    private func updateLanguage(_ language: Language) {
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        
        if let userId = currentUser?.id {
            persistenceManager.updateUserSettings(userId: userId, language: language.rawValue)
        }
    }
    
    private func loadExchangeRates(for currency: Currency) async {
        do {
            let rates = try await currencyService.getExchangeRates(for: "USD")
            await MainActor.run {
                self.exchangeRates = rates
            }
            
            if let userId = currentUser?.id {
                persistenceManager.updateUserSettings(userId: userId, currency: currency.rawValue)
            }
        } catch {
            print("Failed to load exchange rates: \(error)")
        }
    }
    
    func convertPrice(_ price: Double) -> Double {
        return currencyService.convertPrice(
            price,
            from: "USD",
            to: currentCurrency.rawValue,
            rates: exchangeRates
        )
    }
    
    func formatPrice(_ price: Double) -> String {
        let convertedPrice = convertPrice(price)
        return "\(currentCurrency.symbol)\(String(format: "%.2f", convertedPrice))"
    }
}
