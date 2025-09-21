//
//  GiftRecipientSelectorView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct GiftRecipientSelectorView: View {
    @Binding var selectedRecipient: User?
    @Binding var giftMessage: String
    @Environment(\.dismiss) private var dismiss
    @State private var availableUsers: [User] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var errorMessage: String?
    @State private var showingError = false
    @EnvironmentObject var appState: AppState
    
    private let userService = UserService()
    private let logger = DebugLogger.shared
    
    private var filteredUsers: [User] {
        let otherUsers = availableUsers.filter { $0.id != appState.currentUser?.id }
        
        if searchText.isEmpty {
            return otherUsers
        }
        
        return otherUsers.filter { user in
            user.username.localizedCaseInsensitiveContains(searchText) ||
            user.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("loading_recipients".localized())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredUsers.isEmpty && !searchText.isEmpty {
                    noSearchResultsView
                } else if availableUsers.isEmpty {
                    emptyStateView
                } else {
                    recipientsList
                }
            }
            .navigationTitle("gift_options".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized()) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized()) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedRecipient == nil)
                }
            }
            .searchable(text: $searchText, prompt: "Search users")
            .task {
                await loadUsersFromAPI()
            }
            .alert("error".localized(), isPresented: $showingError) {
                Button("retry".localized()) {
                    Task {
                        await loadUsersFromAPI()
                    }
                }
                Button("cancel".localized()) {
                    dismiss()
                }
            } message: {
                Text(errorMessage ?? "failed_load_users".localized())
            }
        }
    }
    
    private var recipientsList: some View {
        VStack(spacing: 0) {
            // Gift Message Section
            VStack(alignment: .leading, spacing: 12) {
                Label("gift_message_optional".localized(), systemImage: "envelope")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextEditor(text: $giftMessage)
                    .frame(height: 80)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Text("gift_message_help".localized())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            // Recipients List
            ScrollView {
                VStack(spacing: 8) {
                    if filteredUsers.isEmpty {
                        Text("No matching users")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 40)
                    } else {
                        ForEach(filteredUsers) { user in
                            RecipientRow(
                                user: user,
                                isSelected: selectedRecipient?.id == user.id
                            ) {
                                withAnimation {
                                    if selectedRecipient?.id == user.id {
                                        selectedRecipient = nil
                                    } else {
                                        selectedRecipient = user
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("no_users_available".localized())
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Try again later")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                Task {
                    await loadUsersFromAPI()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("retry".localized())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var noSearchResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No users found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func loadUsersFromAPI() async {
        isLoading = true
        errorMessage = nil
        do {
            // Fetch users from the API
            let users = try await userService.fetchAllUsers()
            
            await MainActor.run {
                self.availableUsers = users
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
}
