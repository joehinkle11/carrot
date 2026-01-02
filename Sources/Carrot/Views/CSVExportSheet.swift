// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct CSVExportSheet: View {
    let trackableName: String
    let isExportingAll: Bool
    let startDate: Date
    let endDate: Date
    let onExportAll: (() -> Void)?
    
    @Environment(\.dismiss) var dismiss
    @State var copied = false
    
    private var currentCSVContent: String {
        isExportingAll ? allCSVContent : csvContent
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.timeZone = TimeZone.current
        return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                exportIndicator
                csvContentEditor
                actionButtons
            }
            .navigationTitle(isExportingAll ? "All Categories Export" : "\(trackableName) Export")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var exportIndicator: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if isExportingAll {
                    Image("carrotsmall", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.orange)
                } else {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.secondary)
                }
                Text(isExportingAll ? "Exporting all categories" : "Exporting: \(trackableName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.orange)
                Text(dateRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.1))
    }
    
    private var csvContentEditor: some View {
        TextEditor(text: .constant(currentCSVContent))
            .font(.system(.caption, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.secondary.opacity(0.1))
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                copyToClipboard()
            } label: {
                HStack {
                    Image(systemName: copied ? "checkmark" : "square.and.arrow.up")
                    Text(copied ? "Copied!" : "Copy CSV")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(copied ? Color.green : Color.orange)
                .cornerRadius(12)
            }
            
            if !isExportingAll, let exportAll = onExportAll {
                Button {
                    exportAll()
                } label: {
                    HStack {
                        Image("carrotsmall", bundle: .module)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.orange)
                        Text("Export All Categories")
                    }
                    .font(.headline)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    private func copyToClipboard() {
        #if !os(macOS)
        UIPasteboard.general.string = currentCSVContent
        #endif
        
        copied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}
