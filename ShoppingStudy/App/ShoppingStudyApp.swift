//
//  ShoppingStudyApp.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 19.09.2025.
//

import SwiftUI

@main
struct ShoppingStudyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showLaunchScreen = true
    
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
                    .environmentObject(appState)
                    .environmentObject(localizationManager)
                    .environment(\.locale, Locale(identifier: localizationManager.currentLanguage.rawValue))
                    // Removed .withDebugButton()
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageDidChange"))) { _ in
                        appState.objectWillChange.send()
                        localizationManager.objectWillChange.send()
                    }
            }
        }
    }
}
