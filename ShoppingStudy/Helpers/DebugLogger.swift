//
//  DebugLogger.swift
//  ShoppingStudy
//
//  Created by Mustafa Gülden on 21.09.2025.
//

import Foundation
import SwiftUI

// MARK: - Debug Logger for API Calls
final class DebugLogger: ObservableObject {
    static let shared = DebugLogger()
    
    @Published var logs: [APILog] = []
    @Published var isDebugMode = true // Set to false in production
    
    struct APILog: Identifiable {
        let id = UUID()
        let timestamp: Date
        let endpoint: String
        let method: String
        let statusCode: Int?
        let success: Bool
        let errorMessage: String?
        let responseSize: Int?
        let requestBody: String?
        
        var formattedTime: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: timestamp)
        }
        
        var statusEmoji: String {
            success ? "✅" : "❌"
        }
    }
    
    private init() {}
    
    func logRequest(_ endpoint: String, method: String, body: Data? = nil) {
        guard isDebugMode else { return }
        
        let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }
        
        print("""
        🔵 API REQUEST
        ├─ Time: \(Date())
        ├─ Method: \(method)
        ├─ Endpoint: \(endpoint)
        └─ Body: \(bodyString ?? "nil")
        """)
    }
    
    func logResponse(_ endpoint: String, 
                     method: String,
                     statusCode: Int? = nil, 
                     success: Bool,
                     error: Error? = nil,
                     responseData: Data? = nil) {
        guard isDebugMode else { return }
        
        let log = APILog(
            timestamp: Date(),
            endpoint: endpoint,
            method: method,
            statusCode: statusCode,
            success: success,
            errorMessage: error?.localizedDescription,
            responseSize: responseData?.count,
            requestBody: nil
        )
        
        DispatchQueue.main.async {
            self.logs.insert(log, at: 0)
            // Keep only last 100 logs
            if self.logs.count > 100 {
                self.logs = Array(self.logs.prefix(100))
            }
        }
        
        print("""
        \(success ? "🟢" : "🔴") API RESPONSE
        ├─ Time: \(Date())
        ├─ Endpoint: \(endpoint)
        ├─ Status: \(statusCode ?? 0)
        ├─ Success: \(success)
        ├─ Error: \(error?.localizedDescription ?? "none")
        └─ Response Size: \(responseData?.count ?? 0) bytes
        """)
    }
    
    func clearLogs() {
        logs.removeAll()
    }
}

// MARK: - Debug Console View
struct DebugConsoleView: View {
    @StateObject private var logger = DebugLogger.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLog: DebugLogger.APILog?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Debug Mode", isOn: $logger.isDebugMode)
                        .tint(.green)
                    
                    HStack {
                        Text("Total API Calls")
                        Spacer()
                        Text("\(logger.logs.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Success Rate")
                        Spacer()
                        Text(successRate)
                            .fontWeight(.semibold)
                            .foregroundColor(successRateColor)
                    }
                }
                
                Section("API Call History") {
                    if logger.logs.isEmpty {
                        Text("No API calls logged yet")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(logger.logs) { log in
                            APILogRow(log: log)
                                .onTapGesture {
                                    selectedLog = log
                                }
                        }
                    }
                }
            }
            .navigationTitle("🛠 Debug Console")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        logger.clearLogs()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedLog) { log in
                APILogDetailView(log: log)
            }
        }
    }
    
    private var successRate: String {
        guard !logger.logs.isEmpty else { return "N/A" }
        let successCount = logger.logs.filter { $0.success }.count
        let rate = Double(successCount) / Double(logger.logs.count) * 100
        return String(format: "%.1f%%", rate)
    }
    
    private var successRateColor: Color {
        guard !logger.logs.isEmpty else { return .secondary }
        let successCount = logger.logs.filter { $0.success }.count
        let rate = Double(successCount) / Double(logger.logs.count)
        
        if rate >= 0.9 { return .green }
        if rate >= 0.7 { return .orange }
        return .red
    }
}

// MARK: - API Log Row
struct APILogRow: View {
    let log: DebugLogger.APILog
    
    var body: some View {
        HStack {
            Text(log.statusEmoji)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(log.endpoint)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(log.method)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(methodColor.opacity(0.2))
                        .foregroundColor(methodColor)
                        .cornerRadius(4)
                    
                    if let statusCode = log.statusCode {
                        Text("Status: \(statusCode)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(log.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var methodColor: Color {
        switch log.method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT", "PATCH": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }
}

// MARK: - API Log Detail View
struct APILogDetailView: View {
    let log: DebugLogger.APILog
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Request Details") {
                    DetailRow(label: "Timestamp", value: formatDate(log.timestamp))
                    DetailRow(label: "Method", value: log.method)
                    DetailRow(label: "Endpoint", value: log.endpoint)
                }
                
                Section("Response Details") {
                    DetailRow(label: "Success", value: log.success ? "Yes" : "No")
                    
                    if let statusCode = log.statusCode {
                        DetailRow(label: "Status Code", value: "\(statusCode)")
                    }
                    
                    if let size = log.responseSize {
                        DetailRow(label: "Response Size", value: "\(size) bytes")
                    }
                    
                    if let error = log.errorMessage {
                        DetailRow(label: "Error", value: error)
                            .foregroundColor(.red)
                    }
                }
                
                if let body = log.requestBody {
                    Section("Request Body") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(body)
                                .font(.system(.caption, design: .monospaced))
                                .padding()
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("API Call Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Debug Button Modifier
struct DebugButtonModifier: ViewModifier {
    @State private var showingDebugConsole = false
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottomTrailing) {
                if DebugLogger.shared.isDebugMode {
                    Button(action: {
                        showingDebugConsole = true
                    }) {
                        Image(systemName: "ladybug.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                    .sheet(isPresented: $showingDebugConsole) {
                        DebugConsoleView()
                    }
                }
            }
    }
}

extension View {
    func withDebugButton() -> some View {
        modifier(DebugButtonModifier())
    }
}
