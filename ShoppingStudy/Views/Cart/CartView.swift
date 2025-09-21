//
//  CartView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = CartViewModel()
    @State private var showingCheckout = false
    
    var body: some View {
        ZStack {
            if viewModel.cartItems.isEmpty {
                EmptyCartView()
            } else {
                cartContent
            }
        }
        .navigationTitle("cart".localized())
        .toolbar {
            if !viewModel.cartItems.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showClearCartConfirmation()
                    }) {
                        Text("clear_cart".localized())
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadCart(userId: appState.currentUser?.id ?? 0)
        }
        .alert("clear_cart".localized(), isPresented: $viewModel.showingClearCartAlert) {
            Button("cancel".localized(), role: .cancel) {}
            Button("clear_cart".localized(), role: .destructive) {
                viewModel.confirmClearCart(
                    userId: appState.currentUser?.id ?? 0,
                    appState: appState
                )
            }
        } message: {
            Text("confirm_clear_cart".localized())
        }
        .alert("remove_item".localized(), isPresented: $viewModel.showingRemoveAlert) {
            Button("cancel".localized(), role: .cancel) {
                viewModel.cancelRemoveItem()
            }
            Button("remove".localized(), role: .destructive) {
                viewModel.confirmRemoveItem(
                    userId: appState.currentUser?.id ?? 0,
                    appState: appState
                )
            }
        } message: {
            if let item = viewModel.itemToDelete {
                Text("confirm_remove_item".localized(with: item.product.title))
            }
        }
        .sheet(isPresented: $showingCheckout) {
            CheckoutView(
                cartItems: viewModel.cartItems,
                totalAmount: viewModel.totalPrice,
                isGift: viewModel.isGiftMode,
                giftRecipient: viewModel.selectedGiftRecipient,
                giftMessage: viewModel.giftMessage
            )
            .environmentObject(appState)
            .onDisappear {
                // Reload cart when returning from checkout
                viewModel.loadCart(userId: appState.currentUser?.id ?? 0)
            }
        }
        .sheet(isPresented: $viewModel.showingGiftSelector) {
            GiftRecipientSelectorView(
                selectedRecipient: $viewModel.selectedGiftRecipient,
                giftMessage: $viewModel.giftMessage
            )
            .environmentObject(appState)
        }
    }
    
    private var cartContent: some View {
        VStack(spacing: 0) {
            // Gift Mode Toggle
            giftModeSection
            
            // Cart Items List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.cartItems) { item in
                        CartItemRow(
                            item: item,
                            onUpdateQuantity: { newQuantity in
                                viewModel.updateQuantity(
                                    itemId: item.id,
                                    quantity: newQuantity,
                                    userId: appState.currentUser?.id ?? 0,
                                    appState: appState
                                )
                            },
                            onDelete: {
                                viewModel.prepareToRemoveItem(item)
                            }
                        )
                        .environmentObject(appState)
                    }
                }
                .padding()
            }
            
            // Bottom Section
            cartBottomSection
        }
    }
    
    private var giftModeSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: viewModel.isGiftMode ? "gift.fill" : "gift")
                    .foregroundColor(viewModel.isGiftMode ? .white : .blue)
                
                Text(viewModel.isGiftMode ? "gift_enabled".localized() : "send_as_gift".localized())
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.isGiftMode ? .white : .blue)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { viewModel.isGiftMode },
                    set: { _ in viewModel.toggleGiftMode() }
                ))
                .labelsHidden()
            }
            .padding()
            .background(viewModel.isGiftMode ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            if viewModel.isGiftMode {
                VStack(alignment: .leading, spacing: 8) {
                    if let recipient = viewModel.selectedGiftRecipient {
                        HStack {
                            Text("to_recipient".localized(with: recipient.displayName))
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Button("change".localized()) {
                                viewModel.showGiftSelector()
                            }
                            .font(.caption)
                        }
                    } else {
                        Button(action: {
                            viewModel.showGiftSelector()
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("select_recipient".localized())
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    if !viewModel.giftMessage.isEmpty {
                        Text(viewModel.giftMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .animation(.easeInOut, value: viewModel.isGiftMode)
    }
    
    private var cartBottomSection: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.itemCount == 1 ? "one_item".localized() : "multiple_items".localized(with: viewModel.itemCount))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("total".localized())
                        .font(.headline)
                }
                
                Spacer()
                
                Text(appState.formatPrice(viewModel.totalPrice))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            Button(action: {
                showingCheckout = true
            }) {
                HStack {
                    Image(systemName: "creditcard.fill")
                    Text("checkout".localized())
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 5, y: -2)
    }
}
