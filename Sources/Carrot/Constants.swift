// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

enum Constants {
    #if os(iOS)
    static let minusCircleFill = "minus.circle.fill"
    static let advancedToggleIcon = "plusminus.circle"
    static let advancedToggleIconFill = "plusminus.circle.fill"
    #else
    static let minusCircleFill = "arrowtriangle.down.fill"
    static let advancedToggleIcon = "info.circle"
    static let advancedToggleIconFill = "info.circle.fill"
    #endif
}
