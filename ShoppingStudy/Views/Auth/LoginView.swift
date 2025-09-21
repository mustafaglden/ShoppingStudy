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
    @State private var refreshUI = UUID()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 25) {
                    appLogoSection
                    loginFormSection
                }
            }
        }
        .id(refreshUI)
        .alert("error".localized(), isPresented: $viewModel.showingError) {
            Button("ok".localized()) {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $viewModel.showingRegister) {
            RegisterView()
                .environmentObject(appState)
                .environmentObject(localizationManager)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var appLogoSection: some View {
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
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 20) {
            languageSelector
            usernameField
            passwordField
            loginButton
            registerLink
        }
        .padding(.horizontal, 30)
    }
    
    private var languageSelector: some View {
        HStack {
            Text(localizedKey: "language")
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Picker("", selection: $viewModel.selectedLanguage) {
                ForEach(Language.allCases, id: \.self) { language in
                    Text(language.displayName).tag(language)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.selectedLanguage) { _, newValue in
                viewModel.updateLanguage(newValue, appState: appState)
                refreshUI = UUID()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
    
    private var usernameField: some View {
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
    }
    
    private var passwordField: some View {
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
    }
    
    private var loginButton: some View {
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
    }
    
    private var registerLink: some View {
        HStack {
            Text(localizedKey: "dont_have_account")
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: {
                viewModel.showRegisterView()
            }) {
                Text(localizedKey: "register")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
        }
        .font(.footnote)
    }
}
