// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

/// A simple grid of color options that works on both iOS and Android
struct ColorPaletteGrid: View {
    @Binding var selectedColor: String
    
    // Split palette into rows of 5
    private var colorRows: [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        for (index, color) in trackableColorPalette.enumerated() {
            currentRow.append(color)
            if currentRow.count == 5 || index == trackableColorPalette.count - 1 {
                rows.append(currentRow)
                currentRow = []
            }
        }
        return rows
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(colorRows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { hexColor in
                        Button {
                            selectedColor = hexColor
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: hexColor) ?? .orange)
                                    .frame(width: 40, height: 40)
                                
                                if selectedColor == hexColor {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
