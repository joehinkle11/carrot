// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

/// Manages tutorial flags for first-time user experiences
@MainActor
class TutorialManager {
    static let shared = TutorialManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let hasSeenFirstGoalTutorial = "carrot_has_seen_first_goal_tutorial"
        static let hasSeenHistoryDataTutorial = "carrot_has_seen_history_data_tutorial"
    }
    
    private init() {}
    
    // MARK: - First Goal Tutorial
    
    var hasSeenFirstGoalTutorial: Bool {
        get { defaults.bool(forKey: Keys.hasSeenFirstGoalTutorial) }
        set { defaults.set(newValue, forKey: Keys.hasSeenFirstGoalTutorial) }
    }
    
    func markFirstGoalTutorialSeen() {
        hasSeenFirstGoalTutorial = true
    }
    
    // MARK: - History Data Tutorial
    
    var hasSeenHistoryDataTutorial: Bool {
        get { defaults.bool(forKey: Keys.hasSeenHistoryDataTutorial) }
        set { defaults.set(newValue, forKey: Keys.hasSeenHistoryDataTutorial) }
    }
    
    func markHistoryDataTutorialSeen() {
        hasSeenHistoryDataTutorial = true
    }
    
    // MARK: - Reset (for testing)
    
    func resetAllTutorials() {
        hasSeenFirstGoalTutorial = false
        hasSeenHistoryDataTutorial = false
    }
}
