// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct TrackableGridItem: View {
    let trackable: Trackable
    let count: Int
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(trackable.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("\(count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct AdvancedTrackableGridItem: View {
    let trackable: Trackable
    let count: Int
    let color: Color
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(trackable.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("\(count)")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(color)
            
            HStack(spacing: 24) {
                Button(action: onDecrement) {
                    Image(systemName: Constants.minusCircleFill)
                        .font(.title)
                        .foregroundStyle(count > 0 ? color : .secondary)
                }
                .disabled(count == 0)
                
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(color)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
