//
//  FavoritesView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("loading_favorites".localized())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.favoriteProducts.isEmpty {
                emptyFavoritesView
            } else {
                favoritesContent
            }
        }
        .navigationTitle("favorites".localized())
        .task {
            await viewModel.loadFavoriteProducts(favoriteIds: appState.favoriteProductIds)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                await viewModel.loadFavoriteProducts(favoriteIds: appState.favoriteProductIds)
            }
        }
        .sheet(item: $viewModel.selectedProduct) { product in
            ProductDetailView(product: product)
                .environmentObject(appState)
                .onDisappear {
                    viewModel.dismissProductDetail()
                }
        }
        .alert("remove_from_favorites".localized(), isPresented: $viewModel.showingRemoveAlert) {
            Button("cancel".localized(), role: .cancel) {
                viewModel.cancelRemoveFavorite()
            }
            Button("remove".localized(), role: .destructive) {
                viewModel.confirmRemoveFavorite(
                    userId: appState.currentUser?.id ?? 0,
                    appState: appState
                )
            }
        } message: {
            Text("confirm_remove_from_favorites".localized())
        }
    }
    
    private var favoritesContent: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(viewModel.favoriteProducts) { product in
                    FavoriteProductCard(
                        product: product,
                        onRemove: {
                            viewModel.prepareToRemoveFavorite(product)
                        },
                        onAddToCart: {
                            viewModel.addToCart(
                                product: product,
                                userId: appState.currentUser?.id ?? 0,
                                appState: appState
                            )
                        }
                    )
                    .environmentObject(appState)
                    .onTapGesture {
                        viewModel.selectProduct(product)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadFavoriteProducts(favoriteIds: appState.favoriteProductIds)
        }
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("no_favorites".localized())
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("add_products_to_favorites".localized())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: ProductListView()) {
                Text("browse_products".localized())
                    .fontWeight(.medium)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

