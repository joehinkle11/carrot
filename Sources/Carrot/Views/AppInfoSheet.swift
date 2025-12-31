// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct AppInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                Image("carrot", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("Carrot")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                
                Text("Simple Habit Tracker")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                infoDetails
                
                Spacer()
                Spacer()
            }
            .navigationTitle("About")
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
    
    private var infoDetails: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Version")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("1.0.1" as String)
                    .fontWeight(.medium)
            }
            
            Divider()
            
            HStack {
                Text("Created by")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Joseph Hinkle")
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
