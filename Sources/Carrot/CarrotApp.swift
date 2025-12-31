// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation
import SkipFuse
import SwiftUI

/// A logger for the Carrot module.
let logger: Logger = Logger(subsystem: "co.joehink.carrot", category: "Carrot")

/// The shared top-level view for the app, loaded from the platform-specific App delegates below.
/* SKIP @bridge */public struct CarrotRootView : View {
    /* SKIP @bridge */public init() {
    }

    public var body: some View {
        ContentView()
    }
}

/// Global application delegate functions.
/* SKIP @bridge */public final class CarrotAppDelegate : Sendable {
    /* SKIP @bridge */public static let shared = CarrotAppDelegate()

    private init() {
    }

    /* SKIP @bridge */public func onInit() {
        logger.debug("onInit")
    }

    /* SKIP @bridge */public func onLaunch() {
        logger.debug("onLaunch")
    }

    /* SKIP @bridge */public func onResume() {
        logger.debug("onResume")
    }

    /* SKIP @bridge */public func onPause() {
        logger.debug("onPause")
    }

    /* SKIP @bridge */public func onStop() {
        logger.debug("onStop")
    }

    /* SKIP @bridge */public func onDestroy() {
        logger.debug("onDestroy")
    }

    /* SKIP @bridge */public func onLowMemory() {
        logger.debug("onLowMemory")
    }
}
