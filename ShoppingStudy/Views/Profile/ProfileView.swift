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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                userHeaderSection
                statisticsSection
                quickActionsSection
                purchaseHistorySection
                logoutButton
            }
            .padding()
        }
        .navigationTitle("profile".localized())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.showSettings()
                }) {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsView()
                .environmentObject(appState)
                .onDisappear {
                    viewModel.dismissSettings()
                }
        }
        .sheet(item: $viewModel.selectedCart) { cart in
            CartDetailView(cart: cart, viewModel: viewModel)
                .environmentObject(appState)
                .onDisappear {
                    viewModel.dismissCartDetail()
                }
        }
        .alert("logout".localized(), isPresented: $viewModel.showingLogoutAlert) {
            Button("cancel".localized(), role: .cancel) {}
            Button("logout".localized(), role: .destructive) {
                viewModel.performLogout(appState: appState)
            }
        } message: {
            Text("logout_confirmation".localized())
        }
        .task {
            if let userId = appState.currentUser?.id {
                await viewModel.loadUserCarts(userId: userId)
            }
        }
    }
    
    private var userHeaderSection: some View {
        VStack(spacing: 12) {
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
                StatCard(
                    title: "total_purchases".localized(),
                    value: appState.formatPrice(
                        viewModel.calculateTotalPurchases(
                            localTotal: appState.totalAmountSpent
                        )
                    ),
                    icon: "cart.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "orders".localized(),
                    value: "\(viewModel.userCarts.count)",
                    icon: "doc.text.fill",
                    color: .green
                )
                
                StatCard(
                    title: "favorite_products".localized(),
                    value: "\(appState.favoriteProductIds.count)",
                    icon: "heart.fill",
                    color: .red
                )
                
                StatCard(
                    title: "gifts_sent".localized(),
                    value: "\(appState.currentUser?.giftsSent.count ?? 0)",
                    icon: "gift.fill",
                    color: .purple
                )
            }
            
            if let receivedCount = appState.currentUser?.giftsReceived.count, receivedCount > 0 {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    StatCard(
                        title: "gifts_received".localized(),
                        value: "\(receivedCount)",
                        icon: "gift.fill",
                        color: .orange
                    )
                    
                    Color.clear
                        .frame(height: 1)
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AppSettingStatCard(
                    title: "language".localized(),
                    subtitle: appState.currentLanguage.displayName,
                    icon: "globe",
                    color: .blue
                )
                
                AppSettingStatCard(
                    title: "currency".localized(),
                    subtitle: appState.currentCurrency.displayName,
                    icon: "dollarsign.circle",
                    color: .green
                )
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
                emptyHistoryView
            } else {
                ForEach(viewModel.userCarts.prefix(5)) { cart in
                    CartHistoryRow(cart: cart, viewModel: viewModel)
                        .onTapGesture {
                            viewModel.selectCart(cart)
                        }
                }
                
                if viewModel.userCarts.count > 5 {
                    Button(action: {}) {
                        HStack {
                            Text("view_all_orders".localized(with: viewModel.userCarts.count))
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
    
    private var emptyHistoryView: some View {
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
    }
    
    private var logoutButton: some View {
        Button(action: {
            viewModel.confirmLogout()
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
