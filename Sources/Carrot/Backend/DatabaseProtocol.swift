// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

/// Protocol defining the database interface for the app
protocol DatabaseProtocol {
    // MARK: - Trackables
    
    /// Get all trackables
    func getAllTrackables() throws -> [Trackable]
    
    /// Create a new trackable
    func createTrackable(name: String) throws -> Trackable
    
    /// Update an existing trackable
    func updateTrackable(_ trackable: Trackable) throws
    
    /// Delete a trackable by ID
    func deleteTrackable(id: Int64) throws
    
    // MARK: - Counts
    
    /// Get count for a trackable on a specific date
    func getCount(trackableId: Int64, date: String) throws -> Count?
    
    /// Get all counts for a trackable
    func getAllCounts(trackableId: Int64) throws -> [Count]
    
    /// Increment count for a trackable on a specific date
    func incrementCount(trackableId: Int64, date: String) throws -> Count
    
    /// Set count for a trackable on a specific date
    func setCount(trackableId: Int64, date: String, count: Int) throws -> Count
}
