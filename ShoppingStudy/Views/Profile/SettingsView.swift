//
//  SettingsView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("language".localized()) {
                    Picker("language".localized(), selection: $appState.currentLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: appState.currentLanguage) { _, newValue in
                        LocalizationManager.shared.setLanguage(newValue)
                        if let userId = appState.currentUser?.id {
                            UserPersistenceManager.shared.updateUserSettings(
                                userId: userId,
                                language: newValue.rawValue
                            )
                        }
                    }
                }
                
                Section("currency".localized()) {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        HStack {
                            Text("\(currency.symbol) \(currency.displayName)")
                            Spacer()
                            if appState.currentCurrency == currency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appState.currentCurrency = currency
                            if let userId = appState.currentUser?.id {
                                UserPersistenceManager.shared.updateUserSettings(
                                    userId: userId,
                                    currency: currency.rawValue
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("settings".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized()) {
                        dismiss()
                    }
                }
            }
        }
    }
}
