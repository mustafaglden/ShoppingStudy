//
//  ProductListView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProductListViewModel()
    @State private var selectedProduct: Product?
    @State private var showingProductDetail = false
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("loading".localized())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            } else if viewModel.filteredProducts.isEmpty && !viewModel.isLoading {
                EmptyStateView()
            } else {
                productListContent
            }
        }
        .navigationTitle("products".localized())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                currencyButton
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "search".localized())
        .task {
            await viewModel.loadProducts()
        }
        .refreshable {
            await viewModel.refreshProducts()
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
                .environmentObject(appState)
        }
        .alert("error".localized(), isPresented: $viewModel.showingError) {
            Button("ok".localized()) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var productListContent: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Category Filter
                categoryPicker
                
                // Sort Options
                sortPicker
                
                // Products Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(viewModel.filteredProducts) { product in
                        ProductCardView(
                            product: product,
                            isFavorite: appState.favoriteProductIds.contains(product.id)
                        ) {
                            // Add to cart action
                            viewModel.addToCart(
                                product: product,
                                quantity: 1,
                                userId: appState.currentUser?.id ?? 0,
                                appState: appState
                            )
                        } onFavorite: {
                            // Toggle favorite action
                            viewModel.toggleFavorite(
                                productId: product.id,
                                userId: appState.currentUser?.id ?? 0,
                                appState: appState
                            )
                        }
                        .onTapGesture {
                            selectedProduct = product
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChip(
                        title: category == "all" ? "all".localized() : category.capitalized,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation {
                            viewModel.selectedCategory = category
                        }
                        Task(priority: .userInitiated) {
                            await viewModel.loadProductsByCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var sortPicker: some View {
        HStack {
            Text("Sort by:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker("", selection: $viewModel.sortOption) {
                Text("original".localized()).tag(SortOption.none)
                Text("Price: Low to High").tag(SortOption.priceAsc)
                Text("Price: High to Low").tag(SortOption.priceDesc)
                Text("Rating: High to Low").tag(SortOption.rating)
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(.blue)
            
            Spacer()
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                        Text("Clear search")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var currencyButton: some View {
        Menu {
            ForEach(Currency.allCases, id: \.self) { currency in
                Button(action: {
                    appState.currentCurrency = currency
                }) {
                    HStack {
                        Text("\(currency.symbol) \(currency.displayName)")
                        if appState.currentCurrency == currency {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text(appState.currentCurrency.symbol)
                .font(.headline)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    }
}
