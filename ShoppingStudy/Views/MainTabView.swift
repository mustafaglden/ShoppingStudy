//
//  MainTabView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ProductListView()
            }
            .tabItem {
                Label("products".localized(), systemImage: "bag.fill")
            }
            .tag(0)
            .badge(0)
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("favorites".localized(), systemImage: "heart.fill")
            }
            .tag(1)
            .if(appState.favoriteProductIds.count > 0) { view in
                view.badge(appState.favoriteProductIds.count)
            }
            
            NavigationStack {
                CartView()
            }
            .tabItem {
                Label("cart".localized(), systemImage: "cart.fill")
            }
            .tag(2)
            .if(appState.cartItemCount > 0) { view in
                view.badge(appState.cartItemCount)
            }
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("profile".localized(), systemImage: "person.fill")
            }
            .tag(3)
        }
        .tint(Color.blue)
    }
}
