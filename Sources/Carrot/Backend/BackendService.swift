// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

/// Singleton backend service for managing trackables and counts
@MainActor
final class BackendService {
    static let shared = BackendService()
    
    private var database: DatabaseProtocol
    
    private init() {
        // TODO: Replace with real database implementation
        self.database = StubDatabase()
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - Stub Database (temporary)

/// A stub database that does nothing - will be replaced by InMemoryDB in Milestone 4
private class StubDatabase: DatabaseProtocol {
    func getAllTrackables() throws -> [Trackable] {
        return []
    }
    
    func createTrackable(name: String) throws -> Trackable {
        return Trackable(id: 0, name: name)
    }
    
    func updateTrackable(_ trackable: Trackable) throws {
        // No-op
    }
    
    func deleteTrackable(id: Int64) throws {
        // No-op
    }
    
    func getCount(trackableId: Int64, date: String) throws -> Count? {
        return nil
    }
    
    func getAllCounts(trackableId: Int64) throws -> [Count] {
        return []
    }
    
    func incrementCount(trackableId: Int64, date: String) throws -> Count {
        return Count(id: 0, date: date, trackableId: trackableId, count: 1)
    }
    
    func setCount(trackableId: Int64, date: String, count: Int) throws -> Count {
        return Count(id: 0, date: date, trackableId: trackableId, count: count)
    }
}
