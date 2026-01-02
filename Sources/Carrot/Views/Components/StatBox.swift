// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct StatBox: View {
    let title: LocalizedStringKey
    let value: String
    var color: Color = .orange
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}
