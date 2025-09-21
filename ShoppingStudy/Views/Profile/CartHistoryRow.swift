//
//  CartHistoryRow.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import SwiftUI

struct CartHistoryRow: View {
    let cart: GetCartsResponse
    let viewModel: ProfileViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "bag.fill")
                    .foregroundColor(.blue)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("order_number".localized(with: cart.id))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(itemCountText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Price
            Text(appState.formatPrice(viewModel.calculateCartTotal(cart: cart)))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var itemCountText: String {
        let count = cart.products.count
        if count == 1 {
            return "one_item".localized()
        } else {
            return "multiple_items".localized(with: count)
        }
    }
    
    private var formattedDate: String {
        // Parse the date string
        guard let date = ISO8601DateFormatter().date(from: cart.date) else {
            // If can't parse, try without milliseconds
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(identifier: "UTC")
            
            if let fallbackDate = formatter.date(from: cart.date) {
                return formatDate(fallbackDate)
            }
            return cart.date
        }
        return formatDate(date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        
        let relativeDate = formatter.localizedString(for: date, relativeTo: Date())
        
        // If it's very old (like 2020), show the actual date
        let calendar = Calendar.current
        if let years = calendar.dateComponents([.year], from: date, to: Date()).year, years >= 2 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: date)
        }
        
        return relativeDate
    }
}
