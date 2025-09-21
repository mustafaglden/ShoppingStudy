//
//  RegisterView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            
                            Text("register".localized())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        
                        // Registration Form
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("email".localized())
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.caption)
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                    TextField("email".localized(), text: $viewModel.email)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .keyboardType(.emailAddress)
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                            }
                            
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("username".localized())
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.caption)
                                
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                    TextField("username".localized(), text: $viewModel.username)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("password".localized())
                                    .foregroundColor(.white.opacity(0.9))
                                    .font(.caption)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                    SecureField("password".localized(), text: $viewModel.password)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                
                                Text("password_too_short".localized())
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            // Register Button
                            Button(action: {
                                Task {
                                    await viewModel.register(appState: appState)
                                }
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("register".localized())
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .foregroundColor(Color.green)
                            .cornerRadius(10)
                            .disabled(viewModel.isLoading)
                            
                            // Login Link
                            HStack {
                                Text("already_have_account".localized())
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("login".localized())
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }
                            }
                            .font(.footnote)
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
            .alert("error".localized(), isPresented: $viewModel.showingError) {
                Button("ok".localized()) {
                    viewModel.showingError = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.title2)
                    }
                }
            }
        }
    }
}
