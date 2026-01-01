// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

/// Protocol defining the database interface for the app
protocol DatabaseProtocol {
    // MARK: - Trackables
    
    /// Get all trackables sorted by order then id
    func getAllTrackables() throws -> [Trackable]
    
    /// Create a new trackable with name, color and order
    func createTrackable(name: String, color: String, order: Int) throws -> Trackable
    
    /// Update an existing trackable (name, color, order)
    func updateTrackable(_ trackable: Trackable) throws
    
    /// Delete a trackable by ID
    func deleteTrackable(id: Int64) throws
    
    /// Update the order of multiple trackables at once
    func updateTrackableOrders(_ updates: [(id: Int64, order: Int)]) throws
    
    // MARK: - Counts
    
    /// Get count for a trackable on a specific date
    func getCount(trackableId: Int64, date: String) throws -> Count?
    
    /// Get all counts for a trackable
    func getAllCounts(trackableId: Int64) throws -> [Count]
    
    /// Increment count for a trackable on a specific date
    func incrementCount(trackableId: Int64, date: String) throws -> Count
    
    /// Decrement count for a trackable on a specific date (minimum 0)
    func decrementCount(trackableId: Int64, date: String) throws -> Count
    
    /// Set count for a trackable on a specific date
    func setCount(trackableId: Int64, date: String, count: Int) throws -> Count
}
