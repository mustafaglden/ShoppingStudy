//
//  ProductListViewModel.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI
import Combine

@MainActor
final class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var filteredProducts: [Product] = []
    @Published var categories: [String] = []
    @Published var selectedCategory = "all"
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingError = false
    @Published var sortOption: SortOption = .none
    
    private let productService: ProductServiceProtocol
    private let persistenceManager = UserPersistenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    private let logger = DebugLogger.shared
    
    init(productService: ProductServiceProtocol = ProductService()) {
        self.productService = productService
        setupObservers()
    }
    
    private func setupObservers() {
        // Combine all filters into one pipeline
        Publishers.CombineLatest3($searchText, $selectedCategory, $sortOption)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load categories first
            let fetchedCategories = try await productService.fetchCategories()
            
            // Then load products based on selected category
            let fetchedProducts: [Product]
            if selectedCategory == "all" {
                fetchedProducts = try await productService.fetchProducts(
                    limit: nil,
                    sort: nil,
                    category: nil
                )
            } else {
                fetchedProducts = try await productService.fetchProducts(
                    limit: nil,
                    sort: nil,
                    category: selectedCategory
                )
            }
            
            await MainActor.run {
                self.categories = ["all"] + fetchedCategories
                self.products = fetchedProducts

                self.applyFiltersAndSort()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showingError = true
                self.isLoading = false
            }
        }
    }
    
    func loadProductsByCategory(_ category: String) async {
        isLoading = true
        selectedCategory = category
        do {
            let fetchedProducts: [Product]
            if category == "all" {
                fetchedProducts = try await productService.fetchProducts(
                    limit: nil,
                    sort: nil,
                    category: nil
                )
            } else {
                fetchedProducts = try await productService.fetchProducts(
                    limit: nil,
                    sort: nil,
                    category: category
                )
            }
            
            await MainActor.run {
                self.products = fetchedProducts
                self.applyFiltersAndSort()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.showingError = true
                self.isLoading = false
            }
        }
    }
    
    private func applyFiltersAndSort() {
        var result = products
        
        // Step 1: Apply search filter
        if !searchText.isEmpty {
            result = result.filter { product in
                product.title.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch sortOption {
        case .none:
            // Keep original order
            break
        case .priceAsc:
            result.sort { $0.price < $1.price }
        case .priceDesc:
            result.sort { $0.price > $1.price }
        case .rating:
            result.sort { $0.rating.rate > $1.rating.rate }
        }
        
        filteredProducts = result
    }
    
    func toggleFavorite(productId: Int, userId: Int, appState: AppState) {
        let isFavorite = persistenceManager.toggleFavorite(productId: productId, for: userId)
        appState.updateFavorites()
        
        let message = isFavorite ? "Added to favorites" : "Removed from favorites"
    }
    
    func addToCart(product: Product, quantity: Int, userId: Int, appState: AppState) {
        persistenceManager.addToCart(product: product, quantity: quantity, for: userId)
        appState.updateCart()
    }
    
    func isFavorite(productId: Int, userId: Int) -> Bool {
        return persistenceManager.isFavorite(productId: productId, for: userId)
    }
    
    func refreshProducts() async {
        await loadProducts()
    }
}
