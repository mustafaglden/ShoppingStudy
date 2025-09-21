//
//  ShoppingStudyApp.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 19.09.2025.
//

import SwiftUI

@main
struct ShoppingStudyApp: App {
    @StateObject private var appState: AppState
    @StateObject private var localizationManager: LocalizationManager
    @State private var showLaunchScreen = true
    
    init() {
        let persistenceManager = UserPersistenceManager.shared
        let currencyService = CurrencyService()
        
        let appState = AppState(
            persistenceManager: persistenceManager,
            currencyService: currencyService
        )
        
        self._appState = StateObject(wrappedValue: appState)
        self._localizationManager = StateObject(wrappedValue: LocalizationManager.shared)
    }
    
    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                RootView()
                    .environmentObject(appState as AppState)
                    .environmentObject(localizationManager as LocalizationManager)
                    .environment(\.locale, Locale(identifier: localizationManager.currentLanguage.rawValue))
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageDidChange"))) { _ in
                        appState.objectWillChange.send()
                        localizationManager.objectWillChange.send()
                    }
            }
        }
    }
}
