// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation

/// In-memory database implementation that fakes SQL database behavior
/// This will be replaced with SkipSQL in Milestone 5
class InMemoryDB: DatabaseProtocol {
    private var trackables: [Int64: Trackable] = [:]
    private var counts: [Int64: Count] = [:]
    
    private var nextTrackableId: Int64 = 1
    private var nextCountId: Int64 = 1
    
    init() {}
    
    // MARK: - Trackables
    
    func getAllTrackables() throws -> [Trackable] {
        // Sort by order first, then by id for stable sorting
        return Array(trackables.values).sorted { 
            if $0.order != $1.order {
                return $0.order < $1.order
            }
            return $0.id < $1.id
        }
    }
    
    func createTrackable(name: String, color: String, order: Int) throws -> Trackable {
        let id = nextTrackableId
        nextTrackableId += 1
        let trackable = Trackable(id: id, name: name, color: color, order: order)
        trackables[id] = trackable
        return trackable
    }
    
    func updateTrackable(_ trackable: Trackable) throws {
        guard trackables[trackable.id] != nil else {
            throw DatabaseError.notFound
        }
        trackables[trackable.id] = trackable
    }
    
    func updateTrackableOrders(_ updates: [(id: Int64, order: Int)]) throws {
        for update in updates {
            guard var trackable = trackables[update.id] else {
                throw DatabaseError.notFound
            }
            trackable.order = update.order
            trackables[update.id] = trackable
        }
    }
    
    func deleteTrackable(id: Int64) throws {
        guard trackables[id] != nil else {
            throw DatabaseError.notFound
        }
        trackables.removeValue(forKey: id)
        
        // Also delete all counts for this trackable
        let countsToDelete = counts.values.filter { $0.trackableId == id }
        for count in countsToDelete {
            counts.removeValue(forKey: count.id)
        }
    }
    
    // MARK: - Counts
    
    func getCount(trackableId: Int64, date: String) throws -> Count? {
        return counts.values.first { $0.trackableId == trackableId && $0.date == date }
    }
    
    func getAllCounts(trackableId: Int64) throws -> [Count] {
        return counts.values
            .filter { $0.trackableId == trackableId }
            .sorted { $0.date > $1.date }  // Most recent first
    }
    
    func incrementCount(trackableId: Int64, date: String) throws -> Count {
        if let existing = try getCount(trackableId: trackableId, date: date) {
            let updated = Count(id: existing.id, date: date, trackableId: trackableId, count: existing.count + 1)
            counts[existing.id] = updated
            return updated
        } else {
            let id = nextCountId
            nextCountId += 1
            let newCount = Count(id: id, date: date, trackableId: trackableId, count: 1)
            counts[id] = newCount
            return newCount
        }
    }
    
    func decrementCount(trackableId: Int64, date: String) throws -> Count {
        if let existing = try getCount(trackableId: trackableId, date: date) {
            let newCountValue = max(0, existing.count - 1)
            let updated = Count(id: existing.id, date: date, trackableId: trackableId, count: newCountValue)
            counts[existing.id] = updated
            return updated
        } else {
            let id = nextCountId
            nextCountId += 1
            let newCount = Count(id: id, date: date, trackableId: trackableId, count: 0)
            counts[id] = newCount
            return newCount
        }
    }
    
    func setCount(trackableId: Int64, date: String, count: Int) throws -> Count {
        if let existing = try getCount(trackableId: trackableId, date: date) {
            let updated = Count(id: existing.id, date: date, trackableId: trackableId, count: count)
            counts[existing.id] = updated
            return updated
        } else {
            let id = nextCountId
            nextCountId += 1
            let newCount = Count(id: id, date: date, trackableId: trackableId, count: count)
            counts[id] = newCount
            return newCount
        }
    }
}

// MARK: - Database Errors

enum DatabaseError: Error {
    case notFound
    case invalidData
}
