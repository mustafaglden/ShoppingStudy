//
//  ProfileView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingSettings = false
    @State private var showingLogoutAlert = false
    @State private var selectedCart: GetCartsResponse?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User Header
                userHeaderSection
                
                // Statistics (from AppState only)
                statisticsSection
                
                // Quick Actions
                quickActionsSection
                
                // Purchase History (from API)
                purchaseHistorySection
                
                // Logout Button
                logoutButton
            }
            .padding()
        }
        .navigationTitle("profile".localized())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(appState)
        }
        .sheet(item: $selectedCart) { cart in
            CartDetailView(cart: cart, viewModel: viewModel)
                .environmentObject(appState)
        }
        .alert("logout".localized(), isPresented: $showingLogoutAlert) {
            Button("cancel".localized(), role: .cancel) {}
            Button("logout".localized(), role: .destructive) {
                appState.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .task {
            if let userId = appState.currentUser?.id {
                await viewModel.loadUserCarts(userId: userId)
            }
        }
    }
    
    private var userHeaderSection: some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(appState.currentUser?.username.prefix(2).uppercased() ?? "??")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // User Info
            VStack(spacing: 4) {
                Text(appState.currentUser?.username ?? "")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(appState.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical)
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("statistics".localized())
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                // Total amount spent (from local AppState)
                StatCard(
                    title: "total_purchases".localized(),
                    value: appState.formatPrice(appState.currentUser?.totalPurchases ?? 0),
                    icon: "cart.fill",
                    color: .blue
                )
                
                // API carts count
                StatCard(
                    title: "Orders",
                    value: "\(viewModel.userCarts.count)",
                    icon: "doc.text.fill",
                    color: .green
                )
                
                // Favorite products count (from local AppState)
                StatCard(
                    title: "favorite_products".localized(),
                    value: "\(appState.favoriteProductIds.count)",
                    icon: "heart.fill",
                    color: .red
                )
                
                // Gifts sent count (from local AppState)
                StatCard(
                    title: "Gifts Sent",
                    value: "\(appState.currentUser?.giftsSent.count ?? 0)",
                    icon: "gift.fill",
                    color: .purple
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "language".localized(),
                    subtitle: appState.currentLanguage.displayName,
                    icon: "globe",
                    color: .blue
                ) {
                    showingSettings = true
                }
                
                QuickActionButton(
                    title: "currency".localized(),
                    subtitle: appState.currentCurrency.displayName,
                    icon: "dollarsign.circle",
                    color: .green
                ) {
                    showingSettings = true
                }
            }
        }
    }
    
    private var purchaseHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("purchase_history".localized())
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isLoadingCarts {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Text("orders_count".localized(with: viewModel.userCarts.count))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.isLoadingCarts {
                HStack {
                    Spacer()
                    ProgressView("loading_purchase_history".localized())
                        .padding(.vertical, 30)
                    Spacer()
                }
            } else if viewModel.userCarts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("no_purchase_history".localized())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("no_purchases_yet".localized())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            } else {
                ForEach(viewModel.userCarts.prefix(5)) { cart in
                    CartHistoryRow(cart: cart, viewModel: viewModel)
                        .onTapGesture {
                            selectedCart = cart
                        }
                }
                
                if viewModel.userCarts.count > 5 {
                    Button(action: {
                        // Could navigate to full history view
                    }) {
                        HStack {
                            Text("View all \(viewModel.userCarts.count) orders")
                                .font(.caption)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
    
    private var logoutButton: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "arrow.right.square")
                Text("logout".localized())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(10)
        }
        .padding(.top)
    }
}
