//
//  RootView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 20.09.2025.
//

import SwiftUI

//struct RootView: View {
//    @EnvironmentObject var appState: AppState
//    
//    var body: some View {
//        if appState.isAuthenticated {
//            MainTabView()
//        } else {
//            NavigationStack {
//                LoginView()
//            }
//        }
//    }
//}

// Updated RootView
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var refreshID = UUID()
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
                    .id(refreshID) // Force refresh on language change
            } else {
                NavigationStack {
                    LoginView()
                }
                .id(refreshID) // Force refresh on language change
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageDidChange"))) { _ in
            refreshID = UUID() // Force complete view refresh
        }
    }
}

