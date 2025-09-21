//
//  AppState.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI
import Combine

@MainActor
protocol AppStateProtocol: ObservableObject {
    var currentUser: UserProfile? { get set }
    var isAuthenticated: Bool { get set }
    var currentLanguage: Language { get set }
    var currentCurrency: Currency { get set }
    var exchangeRates: [String: Double] { get set }
    var cartItemCount: Int { get set }
    var totalAmountSpent: Double { get set }
    var favoriteProductIds: Set<Int> { get set }
    var giftsSentCount: Int { get set }
    
    func loadCurrentUser()
    func login(user: UserProfile)
    func logout()
    func updateCart()
    func updateFavorites()
    func updateAfterPurchase()
    func convertPrice(_ price: Double) -> Double
    func formatPrice(_ price: Double) -> String
    func notifyPurchaseCompleted()
}

@MainActor
final class AppState: AppStateProtocol {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false
    @Published var currentLanguage: Language = .english
    @Published var currentCurrency: Currency = .usd
    @Published var exchangeRates: [String: Double] = [:]
    @Published var cartItemCount: Int = 0
    @Published var totalAmountSpent: Double = 0
    @Published var favoriteProductIds: Set<Int> = []
    @Published var giftsSentCount: Int = 0
    
    private let persistenceManager: UserPersistenceManagerProtocol
    private let currencyService: CurrencyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(persistenceManager: UserPersistenceManagerProtocol = UserPersistenceManager.shared,
         currencyService: CurrencyServiceProtocol = CurrencyService()) {
        self.persistenceManager = persistenceManager
        self.currencyService = currencyService
        loadCurrentUser()
        setupObservers()
    }
    
    private func setupObservers() {
        $currentLanguage
            .sink { [weak self] language in
                self?.updateLanguage(language)
            }
            .store(in: &cancellables)
        
        $currentCurrency
            .sink { [weak self] currency in
                Task {
                    await self?.loadExchangeRates(for: currency)
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: Notification.Name("PurchaseCompleted"))
            .sink { [weak self] _ in
                self?.loadCurrentUser()
            }
            .store(in: &cancellables)
    }
    
    func loadCurrentUser() {
        print("📱 Loading current user data...")
        
        if let user = persistenceManager.getCurrentUser() {
            self.currentUser = user
            self.isAuthenticated = true
            self.cartItemCount = user.currentCart.count
            self.totalAmountSpent = user.totalPurchases
            self.favoriteProductIds = user.favorites
            self.giftsSentCount = user.giftsSent.count
            
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
        self.totalAmountSpent = user.totalPurchases
        self.favoriteProductIds = user.favorites
        self.giftsSentCount = user.giftsSent.count
        loadUserPreferences()
    }
    
    func logout() {
        persistenceManager.logout()
        self.currentUser = nil
        self.isAuthenticated = false
        self.cartItemCount = 0
        self.totalAmountSpent = 0
        self.favoriteProductIds = []
        self.giftsSentCount = 0
    }
    
    func updateCart() {
        if let userId = currentUser?.id,
           let user = persistenceManager.getUser(by: userId) {
            self.currentUser = user
            self.cartItemCount = user.currentCart.count
            objectWillChange.send()
        }
    }
    
    func updateFavorites() {
        print("❤️ Updating favorites...")
        if let userId = currentUser?.id,
           let user = persistenceManager.getUser(by: userId) {
            self.currentUser = user
            self.favoriteProductIds = user.favorites
            objectWillChange.send()
        }
    }
    
    func updateAfterPurchase() {
        if let userId = currentUser?.id,
           let user = persistenceManager.getUser(by: userId) {
            self.currentUser = user
            
            // Update only the required metrics
            self.totalAmountSpent = user.totalPurchases
            self.giftsSentCount = user.giftsSent.count
            self.cartItemCount = user.currentCart.count
            
            objectWillChange.send()
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
        UserDefaults.appSuite.set([language.rawValue], forKey: "AppleLanguages")
        guard let user = currentUser else { return }
        if let userId = currentUser?.id {
            persistenceManager.updateUserSettings(userId: userId, currency: user.preferredCurrency, language: language.rawValue)
        }
    }
    
    private func loadExchangeRates(for currency: Currency) async {
        do {
            let rates = try await currencyService.getExchangeRates(for: "USD")
            await MainActor.run {
                self.exchangeRates = rates
            }
            guard let user = currentUser else { return }

            if let userId = currentUser?.id {
                persistenceManager.updateUserSettings(userId: userId, currency: currency.rawValue, language: user.preferredLanguage)
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
    
    func notifyPurchaseCompleted() {
        NotificationCenter.default.post(name: Notification.Name("PurchaseCompleted"), object: nil)
        updateAfterPurchase()
    }
}
