//
//  GiftInfoView.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct GiftInfoView: View {
    let recipient: User
    let giftMessage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("gift".localized(), systemImage: "gift.fill")
                .font(.headline)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("recipient".localized() + ":")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(recipient.username)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                if !giftMessage.isEmpty {
                    Text("message".localized() + ":")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(giftMessage)
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(10)
        }
    }
}
