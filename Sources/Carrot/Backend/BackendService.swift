// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

/// Singleton backend service for managing trackables and counts
@MainActor
final class BackendService {
    static let shared = BackendService()
    
    private var database: DatabaseProtocol
    
    private init() {
        do {
            self.database = try SQLDatabase()
            logger.info("SQLDatabase initialized successfully")
        } catch {
            logger.error("Failed to initialize SQLDatabase: \(error), falling back to InMemoryDB")
            self.database = InMemoryDB()
        }
    }
    
    // MARK: - Trackables API
    
    /// Get all trackables
    func getAllTrackables() -> [Trackable] {
        do {
            return try database.getAllTrackables()
        } catch {
            logger.error("Failed to get trackables: \(error)")
            return []
        }
    }
    
    /// Create a new trackable with the given name
    func createTrackable(name: String) -> Trackable? {
        do {
            return try database.createTrackable(name: name)
        } catch {
            logger.error("Failed to create trackable: \(error)")
            return nil
        }
    }
    
    /// Update an existing trackable
    func updateTrackable(_ trackable: Trackable) -> Bool {
        do {
            try database.updateTrackable(trackable)
            return true
        } catch {
            logger.error("Failed to update trackable: \(error)")
            return false
        }
    }
    
    /// Delete a trackable by ID
    func deleteTrackable(id: Int64) -> Bool {
        do {
            try database.deleteTrackable(id: id)
            return true
        } catch {
            logger.error("Failed to delete trackable: \(error)")
            return false
        }
    }
    
    // MARK: - Counts API
    
    /// Get the count for a trackable on a specific date
    func getCount(trackableId: Int64, date: String) -> Count? {
        do {
            return try database.getCount(trackableId: trackableId, date: date)
        } catch {
            logger.error("Failed to get count: \(error)")
            return nil
        }
    }
    
    /// Get all counts for a trackable
    func getAllCounts(trackableId: Int64) -> [Count] {
        do {
            return try database.getAllCounts(trackableId: trackableId)
        } catch {
            logger.error("Failed to get counts: \(error)")
            return []
        }
    }
    
    /// Increment the count for a trackable on a specific date
    func incrementCount(trackableId: Int64, date: String) -> Count? {
        do {
            return try database.incrementCount(trackableId: trackableId, date: date)
        } catch {
            logger.error("Failed to increment count: \(error)")
            return nil
        }
    }
    
    /// Decrement the count for a trackable on a specific date (minimum 0)
    func decrementCount(trackableId: Int64, date: String) -> Count? {
        do {
            return try database.decrementCount(trackableId: trackableId, date: date)
        } catch {
            logger.error("Failed to decrement count: \(error)")
            return nil
        }
    }
    
    /// Set the count for a trackable on a specific date
    func setCount(trackableId: Int64, date: String, count: Int) -> Count? {
        do {
            return try database.setCount(trackableId: trackableId, date: date, count: count)
        } catch {
            logger.error("Failed to set count: \(error)")
            return nil
        }
    }
    
    // MARK: - Helpers
    
    /// Get today's date as a string in YYYY-MM-DD format
    func todayString() -> String {
        return dateString(from: Date())
    }
    
    /// Convert a Date to a string in YYYY-MM-DD format
    func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
