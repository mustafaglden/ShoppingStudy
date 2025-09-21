//
//  LoginView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var localizationManager: LocalizationManager
    @StateObject private var viewModel = AuthViewModel()
    @State private var showingRegister = false
    @State private var refreshUI = UUID()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // App Logo
                    VStack(spacing: 15) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        
                        Text(localizedKey: "app_name")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                    
                    // Login Form
                    VStack(spacing: 20) {
                        // Language Selector
                        HStack {
                            Text(localizedKey: "language")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Picker("", selection: $localizationManager.currentLanguage) {
                                ForEach(Language.allCases, id: \.self) { language in
                                    Text(language.displayName).tag(language)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: localizationManager.currentLanguage) { _, newValue in
                                localizationManager.setLanguage(newValue)
                                appState.currentLanguage = newValue
                                refreshUI = UUID()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedKey: "username")
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
                            Text(localizedKey: "password")
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
                        }
                        
                        // Login Button
                        Button(action: {
                            Task {
                                await viewModel.login(appState: appState)
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(localizedKey: "login")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .foregroundColor(Color.blue)
                        .cornerRadius(10)
                        .disabled(viewModel.isLoading)
                        
                        // Register Link
                        HStack {
                            Text(localizedKey: "dont_have_account")
                                .foregroundColor(.white.opacity(0.8))
                            
                            Button(action: {
                                showingRegister = true
                            }) {
                                Text(localizedKey: "register")
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
        .id(refreshUI) // Force refresh when language changes
        .alert("error".localized(), isPresented: $viewModel.showingError) {
            Button("ok".localized()) {
                viewModel.showingError = false
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView()
                .environmentObject(appState)
                .environmentObject(localizationManager)
        }
    }
}
