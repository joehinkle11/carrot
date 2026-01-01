// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

struct HistoryEntry: Identifiable {
    let id: String
    let date: Date
    let dateString: String
    let day: Int
    let month: String
    let dayOfWeek: String
    let count: Int
}
