//
//  ContentView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 19.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        RootView()
            .environmentObject(appState)
            .environment(\.locale, Locale(identifier: appState.currentLanguage.rawValue))
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageDidChange"))) { _ in
                appState.objectWillChange.send()
            }
    }
}
