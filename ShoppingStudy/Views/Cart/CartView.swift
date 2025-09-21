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
    @State private var showingClearCartAlert = false
    @State private var itemToDelete: CartItem?
    @State private var showingCheckout = false
    @State private var showingGiftSelector = false
    
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
                        showingClearCartAlert = true
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
        .alert("clear_cart".localized(), isPresented: $showingClearCartAlert) {
            Button("cancel".localized(), role: .cancel) {}
            Button("clear_cart".localized(), role: .destructive) {
                viewModel.clearCart(
                    userId: appState.currentUser?.id ?? 0,
                    appState: appState
                )
            }
        } message: {
            Text("confirm_clear_cart".localized())
        }
        .alert("remove_item".localized(), isPresented: .constant(itemToDelete != nil)) {
            Button("cancel".localized(), role: .cancel) {
                itemToDelete = nil
            }
            Button("remove".localized(), role: .destructive) {
                if let item = itemToDelete {
                    viewModel.removeItem(
                        itemId: item.id,
                        userId: appState.currentUser?.id ?? 0,
                        appState: appState
                    )
                    itemToDelete = nil
                }
            }
        } message: {
            if let item = itemToDelete {
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
        }
        .sheet(isPresented: $showingGiftSelector) {
            GiftRecipientSelectorView(
                selectedRecipient: $viewModel.selectedGiftRecipient,
                giftMessage: $viewModel.giftMessage
            )
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
                                itemToDelete = item
                            }
                        )
                        .environmentObject(appState)
                    }
                }
                .padding()
            }
            
            // Bottom Section
            VStack(spacing: 15) {
                // Summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.itemCount == 1 ? "one_item".localized() : "multiple_items".localized(with: viewModel.itemCount))")
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
                
                // Checkout Button
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
    
    private var giftModeSection: some View {
        VStack(spacing: 12) {
            // Gift Toggle
            HStack {
                Image(systemName: viewModel.isGiftMode ? "gift.fill" : "gift")
                    .foregroundColor(viewModel.isGiftMode ? .white : .blue)
                
                Text(viewModel.isGiftMode ? "gift_enabled".localized() : "send_as_gift".localized())
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.isGiftMode ? .white : .blue)
                
                Spacer()
                
                Toggle("", isOn: $viewModel.isGiftMode)
                    .labelsHidden()
            }
            .padding()
            .background(viewModel.isGiftMode ? Color.blue : Color.blue.opacity(0.1))
            .cornerRadius(10)
            .onTapGesture {
                viewModel.toggleGiftMode()
                if viewModel.isGiftMode {
                    showingGiftSelector = true
                }
            }
            
            // Gift Info (when enabled)
            if viewModel.isGiftMode {
                VStack(alignment: .leading, spacing: 8) {
                    if let recipient = viewModel.selectedGiftRecipient {
                        HStack {
                            Text("to_recipient".localized(with: recipient.displayName))
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Button("change".localized()) {
                                showingGiftSelector = true
                            }
                            .font(.caption)
                        }
                    } else {
                        Button(action: {
                            showingGiftSelector = true
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
}


