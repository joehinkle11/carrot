// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

/// A trackable habit or goal
struct Trackable: Identifiable, Hashable, Codable {
    let id: Int64
    var name: String
    
    init(id: Int64 = 0, name: String) {
        self.id = id
        self.name = name
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
