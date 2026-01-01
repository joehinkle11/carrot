// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

/// Default orange color hex
let defaultTrackableColor = "#FF9500"

/// Predefined color palette for random assignment
let trackableColorPalette: [String] = [
    "#FF9500", // Orange
    "#FF3B30", // Red
    "#34C759", // Green
    "#007AFF", // Blue
    "#AF52DE", // Purple
    "#FF2D55", // Pink
    "#5856D6", // Indigo
    "#00C7BE", // Teal
    "#FFD60A", // Yellow
    "#FF6B35"  // Coral
]

/// Returns a random color from the palette
func randomTrackableColor() -> String {
    return trackableColorPalette.randomElement() ?? defaultTrackableColor
}

/// A trackable habit or goal
struct Trackable: Identifiable, Hashable, Codable {
    let id: Int64
    var name: String
    var color: String
    var order: Int
    
    init(id: Int64 = 0, name: String, color: String = defaultTrackableColor, order: Int = -1) {
        self.id = id
        self.name = name
        self.color = color
        self.order = order
    }
}

/// A count entry for a trackable on a specific date
struct Count: Identifiable, Hashable, Codable {
    let id: Int64
    let date: String  // Format: "YYYY-MM-DD"
    let trackableId: Int64
    var count: Int
    
    init(id: Int64 = 0, date: String, trackableId: Int64, count: Int = 0) {
        self.id = id
        self.date = date
        self.trackableId = trackableId
        self.count = count
    }
}
